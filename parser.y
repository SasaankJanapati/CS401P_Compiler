%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>

extern FILE* yyin;
extern int yylineno; 
int yydebug = 0;

// Forward declarations
void yyerror(const char* s);
int yylex();



// --- Data Structures for Parse Tree ---

typedef struct Node {
    char* type;
    char* value;
    char* data_type; 
    int num_children;
    struct Node** children;
    struct SymbolTable* scope_table; // Points to the symbol table for this node's scope
} Node;

void generate_assembly(struct Node* node, struct SymbolTable* scope);
Node* create_node(char* type, char* value);
void add_child(Node* parent, Node* child);
void print_tree(Node* node, int level);
void write_tree_to_file(Node* node, FILE* file, int level);
Node* root = NULL;

// --- Data Structures for Symbol Table ---

#define TABLE_SIZE 100
#define MAX_PARAMS 20
#define MAX_LOOP_DEPTH 50

typedef struct Symbol {
    char* name;
    char* type;
    char* kind;           // e.g., "variable", "function", "class", "member_var", "object"
    char* access_spec;    // "public", "private", "protected", or "default"
    char* class_name;     // Name of the class if it's a member
    int scope;
    int line_declared;
    int address;          // For code generation (e.g., local variable index)
    char* signature;      // For functions/methods: e.g., "(int,float)->void"
    Node* initializer_node; // For members initialized at declaration
    Node* dimension_info; // For arrays: points to the INDEX node from declaration
} Symbol;

typedef struct SymbolTable {
    Symbol* symbols[TABLE_SIZE];
    int count;
    int scope;
    int base_count; // To track local variable count at scope entry
    struct SymbolTable* parent;
} SymbolTable;

SymbolTable* current_table;
SymbolTable* all_tables[TABLE_SIZE * 10];
int table_count = 0;
int local_address_counter = 0; // For assigning local variable addresses
int params = 0; // Count of parameters in the current function

// --- Data Structures for Class Metadata ---
#define MAX_PARENTS 10
#define MAX_MEMBERS 100

typedef struct ParamInfo {
    char* type;
} ParamInfo;

typedef struct FieldInfo {
    char* name;
    char* type;
    char* access_spec;
    Node* initializer;
} FieldInfo;

typedef struct MethodInfo {
    char* name;
    char* return_type;
    char* access_spec;
    char* signature; // e.g., "(int,float)->void"
    int param_count;
    ParamInfo params[MAX_PARAMS];
    bool is_override;
    bool is_abstract;
    int vtable_index; // Index in the vtable for dynamic dispatch
} MethodInfo;

typedef struct ClassInfo {
    char* name;
    int parent_count;
    char* parent_names[MAX_PARENTS];
    struct ClassInfo* parents[MAX_PARENTS];

    FieldInfo fields[MAX_MEMBERS];
    int field_count;
    MethodInfo methods[MAX_MEMBERS];
    int method_count;

    struct ClassInfo* mro[MAX_PARENTS + 1]; // Method Resolution Order
    int mro_count;

    bool is_abstract;
    struct SymbolTable* symbol_table; // Symbol table for class scope

    int constructors_count;
} ClassInfo;

ClassInfo* class_metadata_pool[TABLE_SIZE];
int class_pool_count = 0;
ClassInfo* current_class_info = NULL; // Pointer to the class currently being parsed

// --- Data Structure for Constant Pool ---
#define CONST_POOL_SIZE 256
char* constant_pool[CONST_POOL_SIZE];
int constant_pool_count = 0;

// --- Helper Functions for Type Checking & Symbol Management ---

char* get_mangled_name(const char* func_name, Node* param_list_node);
bool is_diamond_ancestor(ClassInfo* class_info, ClassInfo* ancestor);
void perform_diamond_check(ClassInfo* class_info);
FieldInfo* find_field_in_hierarchy(const char* field_name, ClassInfo* class_info);
MethodInfo* find_method_in_hierarchy(const char* method_name, const char* signature, ClassInfo* class_info);
ClassInfo* find_class_info(const char* class_name);

Symbol* lookup_symbol_codegen(char* name, SymbolTable* scope, ClassInfo* class_context);
int get_class_index(const char* class_name);
int get_field_index(const char* class_name, const char* field_name);
int get_method_vtable_index(const char* class_name, const char* mangled_name);

char* current_function_return_type;
int has_return_statement;
char* current_class_name = NULL;
char* current_access_spec = "private"; // Default for classes
bool in_class_func = false;

// Forward declarations
void insert_symbol(char* name, char* type, char* kind, Node* initializer, Node* index_node);
ClassInfo* find_class_info(const char* class_name);


// Helper function to recursively build a nested type string for multi-dimensional arrays
char* build_array_type(const char* base_type, Node* index_node) {
    if (index_node == NULL) {
        if (strcmp(base_type,"int")==0) return "I";
        else if (strcmp(base_type,"float")==0) return "F";
        else if (strcmp(base_type,"char")==0) return "C";
        else { 
            char* obj_type = malloc(strlen(base_type) + 3); // L + type + ; + \0
            sprintf(obj_type, "L%s;", base_type);
            return obj_type;
            } 
    }
    char* inner_type;
    // Recursively call for the rest of the dimensions
    if (index_node->num_children == 2) { // case: '[' EXPR ']' INDEX
        inner_type = build_array_type(base_type, index_node->children[1]);
    } else { // base case: '[' EXPR ']'
        inner_type = strdup(base_type);
        if (strcmp(base_type,"int")==0) inner_type = strdup("I");
        else if (strcmp(base_type,"float")==0) inner_type = strdup("F");
        else if (strcmp(base_type,"char")==0) inner_type = strdup("C");
        else { 
            char* obj_type = malloc(strlen(base_type) + 3); // L + type + ; + \0
            sprintf(obj_type, "L%s;", base_type);
            inner_type = obj_type;
        }
    }
    char* final_type = malloc(strlen(inner_type) + 10);
    sprintf(final_type, "[%s", inner_type);
    free(inner_type);
    return final_type;
}


void check_init_list_types(Node* list_node, const char* base_type) {
    if (list_node == NULL) return;
    for (int i = 0; i < list_node->num_children; i++) {
        Node* expr_node = list_node->children[i];
        if (strcmp(expr_node->data_type, base_type) != 0) {
            fprintf(stderr, "Error at line %d: Incompatible type in array initializer. Expected '%s' but got '%s'.\n", yylineno, base_type, expr_node->data_type);
        }
    }
}

int are_types_compatible(char* lval_type, char* rval_type) {
    if (strcmp(lval_type, "undefined") == 0 || strcmp(rval_type, "undefined") == 0) return 1;
    if (strcmp(lval_type, rval_type) == 0) return 1;
    if (strcmp(lval_type, "float") == 0 && strcmp(rval_type, "int") == 0) return 1;
    if (strncmp(lval_type, "[", 1) == 0 && strcmp(rval_type, "int") == 0) return 1; // Allow assigning 0 (null) to arrays
    if (find_class_info(lval_type) != NULL && strcmp(rval_type, "int") == 0) return 1; // Allow assigning 0 (null) to objects

    return 0;
}

int is_numeric(char* type) {
    if (type == NULL) return 0;
    return strcmp(type, "int") == 0 || strcmp(type, "float") == 0;
}

char* get_promoted_type(char* type1, char* type2) {
    if (!is_numeric(type1) || !is_numeric(type2)) return "undefined";
    if (strcmp(type1, "float") == 0 || strcmp(type2, "float") == 0) return "float";
    return "int";
}


// --- Symbol Table Functions ---

void print_table_to_file(SymbolTable* table, FILE* file) {
    if (!table || !file) return;
    fprintf(file, "\n--- Scope: %d (Parent Scope: %d) ---\n", table->scope, table->parent ? table->parent->scope : -1);
    fprintf(file, "%-20s | %-15s | %-12s | %-12s | %-15s| %-12s | %s\n", "Name", "Type", "Kind", "Access", "Class", "Line address" ,"Line Declared");
    fprintf(file, "--------------------------------------------------------------------------------------------------------------------\n");
    for (int i = 0; i < table->count; i++) {
        Symbol* s = table->symbols[i];
        fprintf(file, "%-20s | %-15s | %-12s | %-12s | %-15s | %-12d | %d\n", s->name, s->type, s->kind, s->access_spec, s->class_name ? s->class_name : "N/A", s->address, s->line_declared);
    }
}


void init_symbol_table() {
    current_table = (SymbolTable*)malloc(sizeof(SymbolTable));
    current_table->count = 0;
    current_table->base_count = 0;
    current_table->scope = 0;
    current_table->parent = NULL;
    all_tables[table_count++] = current_table;
}

void enter_scope() {
    SymbolTable* new_table = (SymbolTable*)malloc(sizeof(SymbolTable));
    new_table->count = 0;
    new_table->scope = (current_table->scope) + 1;
    new_table->parent = current_table;
    new_table->base_count = local_address_counter; // Save count for restoring local_address_counter on exit
    current_table = new_table;
    all_tables[table_count++] = new_table;
    fprintf(stderr, "Debug: Entered new scope %d %d\n", new_table->scope, local_address_counter);
    // Reset local address counter only when entering a function-level scope
    
}

void exit_scope() {
    if (current_table->parent != NULL) {
        fprintf(stderr, "Debug: Exited to scope %d %d\n",local_address_counter,current_table->scope);
        current_table = current_table->parent;
        //local_address_counter = current_table->base_count; // Restore local address counter
        fprintf(stderr, "Debug: Exited to scope %d %d\n",local_address_counter,current_table->scope);
    }
}

void insert_symbol(char* name, char* type, char* kind, Node* initializer, Node* index_node) {
    if(current_table->count >= TABLE_SIZE) {
        yyerror("Symbol table overflow.");
        return;
    }
    // For local scopes, check for simple redeclaration.
    // For class scope, overloading (functions with different signatures) is allowed.
    for(int i = 0; i < current_table->count; i++) {
        if(strcmp(current_table->symbols[i]->name, name) == 0) {
            // Allow function overloading in class scope
            if (current_class_info != NULL && strcmp(kind, "member_func") == 0) {
                // A more robust check would involve comparing full signatures here
                continue; 
            }
            fprintf(stderr, "Error line %d: Redeclaration of symbol '%s'\n", yylineno, name);
            return;
        }
    }
    Symbol* s = (Symbol*)calloc(1, sizeof(Symbol));
    s->name = strdup(name);
    s->type = strdup(type);
    s->kind = strdup(kind);
    s->line_declared = yylineno;
    s->access_spec = strdup(current_access_spec);
    s->class_name = current_class_name ? strdup(current_class_name) : NULL;
    s->dimension_info = index_node; // Store dimension info for arrays
    if(strcmp(kind, "variable") == 0 || strcmp(kind, "object") == 0) {
        s->address = local_address_counter++;
    } else if(strcmp(kind, "parameter") == 0) {
        s->address = params++; // Parameters get addresses starting from 0
    } else {
        s->address = -1; // Not a stack-allocatable local variable
    }
        
    current_table->symbols[current_table->count++] = s;

    // If inside a class, also add to the class's specific metadata list
    if (current_class_info) {
        if (strcmp(kind, "member_var") == 0) {
            if (current_class_info->field_count < MAX_MEMBERS) {
                fprintf(stderr, "Debug: Adding member variable '%s' to class '%s'\n", name, current_class_info->name);
                FieldInfo* field = &current_class_info->fields[current_class_info->field_count++];
                field->name = strdup(name);
                field->type = strdup(type);
                field->access_spec = strdup(current_access_spec);
                field->initializer = initializer;
            }
        } else if (strcmp(kind, "member_func") == 0) {
            // This part is handled in the FUNCDECL rule to get the full signature
        } else if (strcmp(kind, "member_obj") == 0) {
            if (current_class_info->field_count < MAX_MEMBERS) {
                FieldInfo* field = &current_class_info->fields[current_class_info->field_count++];
                field->name = strdup(name);
                field->type = strdup(type);
                field->access_spec = strdup(current_access_spec);
                field->initializer = initializer;
            }
        }
    }
}

Symbol* lookup_symbol(char* name) {
    SymbolTable* table = current_table;
    while (table != NULL) {
        for (int i = 0; i < table->count; i++) {
            if (strcmp(table->symbols[i]->name, name) == 0) {
                return table->symbols[i];
            }
        }
        table = table->parent;
    }
    return NULL;
}

Symbol* lookup_in_class_hierarchy(const char* name, ClassInfo* class_info) {
    if (!class_info || !class_info->symbol_table) {
        return NULL;
    }

    // Search for the member in the current class's symbol table.
    SymbolTable* table = class_info->symbol_table;
    for (int i = 0; i < table->count; i++) {
        Symbol* s = table->symbols[i];
        if (strcmp(s->kind, "member_var") == 0 && strcmp(s->name, name) == 0) {
            return s;
        }
    }

    // If not found, recurse on all parent classes.
    for (int i = 0; i < class_info->parent_count; i++) {
        Symbol* s = lookup_in_class_hierarchy(name, class_info->parents[i]);
        if (s) {
            return s;
        }
    }
    
    return NULL;
}


bool is_diamond_ancestor(ClassInfo* class_info, ClassInfo* ancestor_to_find) {
    int paths_found = 0;
    if (class_info == NULL) return false;

    for (int i = 0; i < class_info->parent_count; i++) {
        ClassInfo* parent = class_info->parents[i];
        if (parent == ancestor_to_find) {
            paths_found++;
        }
        if (is_diamond_ancestor(parent, ancestor_to_find)) {
            paths_found++;
        }
    }
    return paths_found > 1;
}

void perform_diamond_check(ClassInfo* class_info) {
    // First, link parent pointers from parent_names
    for (int i = 0; i < class_info->parent_count; i++) {
        class_info->parents[i] = find_class_info(class_info->parent_names[i]);
        if (!class_info->parents[i]) {
            fprintf(stderr, "Error: Parent class '%s' for class '%s' not found.\n", class_info->parent_names[i], class_info->name);
        }
    }

    for (int i = 0; i < class_pool_count; i++) {
        ClassInfo* potential_ancestor = class_metadata_pool[i];
        if (class_info != potential_ancestor && is_diamond_ancestor(class_info, potential_ancestor)) {
             fprintf(stderr, "Error at line %d: Diamond inheritance problem detected. Class '%s' is inherited multiple times by '%s'. The grammar must be extended with 'virtual' inheritance to resolve this ambiguity.\n", yylineno, potential_ancestor->name, class_info->name);
        }
    }
}

int get_total_field_count(ClassInfo* class_info) {
    if (!class_info) return 0;
    int count = class_info->field_count;
    for (int i = 0; i < class_info->parent_count; i++) {
        count += get_total_field_count(class_info->parents[i]);
    }
    return count;
}


// --- Helper Functions for Class and Member Lookups ---
ClassInfo* find_class_info(const char* class_name) {
    //fprintf(stderr, "Debug: fci Looking up class info for '%s'\n", class_name);
    if (class_name == NULL) return NULL;
    for (int i = 0; i < class_pool_count; i++) {
        //fprintf(stderr, "Checking class '%s' against '%s'\n", class_metadata_pool[i]->name, class_name);
        if (strcmp(class_metadata_pool[i]->name, class_name) == 0) {
            return class_metadata_pool[i];
        }
    }
    return NULL;
}

// Get the integer index of a class for the NEW instruction
int get_class_index(const char* class_name) {
    if (class_name == NULL) return -1;
    //printf("Looking up class index for '%s'\n", class_name);
    for (int i = 0; i < class_pool_count; i++) {
        //printf("Checking class '%s'\n", class_metadata_pool[i]->name);
        if (strcmp(class_metadata_pool[i]->name, class_name) == 0) {
            return i;
        }
    }
    return -1; // Not found
}

// Get the integer index of a field for GETFIELD/PUTFIELD, considering inheritance
int get_field_index(const char* class_name, const char* field_name) {
    ClassInfo* cls = find_class_info(class_name);
    //fprintf(stderr, "Debug: Looking up field index for '%s' in class '%s'\n", field_name, class_name);
    if (!cls) return -1;
    //fprintf(stderr, "Looking up field index for '%s' in class '%s'\n", field_name, class_name);
    // Calculate base offset from parents
    int base_offset = 0;
    for(int i = 0; i < cls->parent_count; i++) {
        base_offset += get_total_field_count(cls->parents[i]);
    }
    //fprintf(stderr, "Base offset from parents: %d\n", base_offset);
    
    for (int i = 0; i < cls->field_count; i++) {
        //fprintf(stderr, "Checking field '%s' at index %d (base offset %d) against '%s'\n", cls->fields[i].name, i, base_offset, field_name);
        if (strcmp(cls->fields[i].name, field_name) == 0) return base_offset + i;
    }
    //fprintf(stderr, "Field '%s' not found in class '%s'. Checking parents...\n", field_name, class_name);

    if(cls->parent_count > 0) {
        return get_field_index(cls->parents[0]->name, field_name);
    }

    return -1;
}


// Get the integer vtable index of a method for INVOKEVIRTUAL/INVOKESPECIAL
int get_method_vtable_index(const char* class_name, const char* mangled_name) {
     ClassInfo* cls = find_class_info(class_name);
    if (!cls) return -1;
    //fprintf(stderr, "Debug: Looking up method vtable index for '%s' in class '%s'\n", mangled_name, class_name);
    MethodInfo* method = find_method_in_hierarchy(NULL, mangled_name, cls);
    //fprintf(stderr, "Debug: Method lookup result: %s\n", method ? "found" : "not found");
    if(method) return method->vtable_index;
    
    return -1; // Not found
}

FieldInfo* find_field_in_hierarchy(const char* field_name, ClassInfo* class_info) {
    if (!class_info) return NULL;
    for (int i = 0; i < class_info->field_count; i++) {
        if (strcmp(class_info->fields[i].name, field_name) == 0) {
            return &class_info->fields[i];
        }
    }
    for (int i = 0; i < class_info->parent_count; i++) {
        FieldInfo* field = find_field_in_hierarchy(field_name, class_info->parents[i]);
        if (field) return field;
    }
    return NULL;
}

void check_abstract_implementation(ClassInfo* class_info) {
    if (class_info == NULL || class_info->is_abstract) {
        return; // No check needed for abstract classes themselves.
    }

    // Iterate through all parent classes
    for (int i = 0; i < class_info->parent_count; i++) {
        ClassInfo* parent = class_info->parents[i];
        if (parent == NULL) continue;

        // Iterate through all methods of the parent
        for (int j = 0; j < parent->method_count; j++) {
            MethodInfo* parent_method = &parent->methods[j];

            // If we find an inherited abstract method...
            if (parent_method->is_abstract) {
                bool is_implemented = false;
                // ...check if the current class has implemented it.
                for (int k = 0; k < class_info->method_count; k++) {
                    if (strcmp(class_info->methods[k].signature, parent_method->signature) == 0) {
                        is_implemented = true;
                        break;
                    }
                }

                if (!is_implemented) {
                    fprintf(stderr, "Error line %d: Non-abstract class '%s' must implement inherited abstract method with signature '%s'\n",
                          yylineno, class_info->name, parent_method->signature);
                }
            }
        }
    }
}

char* get_mangled_name(const char* func_name, Node* arg_list_node) {
    char mangled_name[512];
    strcpy(mangled_name, func_name);
    
    if (arg_list_node && strcmp(arg_list_node->type, "PARAM_LIST") == 0) {
        while (arg_list_node && strcmp(arg_list_node->type, "PARAM_LIST") == 0) {
            if (arg_list_node->num_children == 0) break;
            for (int i = 0; i < arg_list_node->num_children; i++) {
                //fprintf(stderr, "Debug: Processing child %d of '%s'\n", i, arg_list_node->type);
                Node* expr_or_param = arg_list_node->children[i];
                //fprintf(stderr, "Debug: Child type: '%s' '%s'\n", expr_or_param->type,mangled_name);

                // Param lists have a different structure than arg lists
                if(strcmp(expr_or_param->type, "PARAM_LIST") == 0) {
                    arg_list_node = expr_or_param;
                    // fprintf(stderr, "mangled name: %s\n", mangled_name);
                    // fprintf(stderr, "Debug: Descending into nested param/arg list '%s'\n", arg_list_node->type);
                    break;
                } else if(strcmp(expr_or_param->type, "PARAM") == 0) {
                    strcat(mangled_name, "@");
                    strcat(mangled_name, expr_or_param->children[0]->value);
                    if(arg_list_node->num_children == 1) {
                        arg_list_node = NULL; // End of list
                        break;
                    }
                } else {
                    //fprintf(stderr, "Debug: Mangling param/arg of type '%s' with data type '%s'\n", expr_or_param->type, expr_or_param->data_type ? expr_or_param->data_type : "NULL");
                    strcat(mangled_name, expr_or_param->data_type ? expr_or_param->data_type : "unknown");
                }
            }
        }
    } else if (arg_list_node && strcmp(arg_list_node->type, "ARG_LIST") == 0) {
        //fprintf(stderr, "mangled name: %s\n", mangled_name);
        for (int i = 0; i < arg_list_node->num_children; i++) {

            //fprintf(stderr, "Debug: Processing child %d of '%s'\n", i, arg_list_node->type);
            //fprintf(stderr, "mangled name: %s\n", mangled_name);
            Node* expr_or_param = arg_list_node->children[i];
            //fprintf(stderr, "Debug: Child type: '%s'\n", expr_or_param->type);
            strcat(mangled_name, "@");
            // Arg lists have a different structure than param lists
            strcat(mangled_name, expr_or_param->data_type ? expr_or_param->data_type : "unknown");
    
        }
    }
    //fprintf(stderr, "Debug: Mangled name generated: '%s'\n", mangled_name);
    return strdup(mangled_name);
}

MethodInfo* find_method_in_hierarchy(const char* method_name, const char* signature, ClassInfo* class_info) {
    if (!class_info) return NULL;
    for (int i = 0; i < class_info->method_count; i++) {
        //fprintf(stderr, "Debug: Checking method '%s' with signature '%s' against '%s'\n", class_info->methods[i].name, class_info->methods[i].signature, signature);
        if (strcmp(class_info->methods[i].signature, signature) == 0) {
            return &class_info->methods[i];
        }
    }
    for (int i = 0; i < class_info->parent_count; i++) {
        MethodInfo* method = find_method_in_hierarchy(method_name, signature, class_info->parents[i]);
        if (method) return method;
    }
    return NULL;
}

void check_for_override(ClassInfo* child, MethodInfo* new_method) {
    for (int i = 0; i < child->parent_count; i++) {
        MethodInfo* parent_method = find_method_in_hierarchy(new_method->name, new_method->signature, child->parents[i]);
        if (parent_method) {
            new_method->is_override = true;
            new_method->vtable_index = parent_method->vtable_index; 
            return;
        }
    }
    new_method->is_override = false;
    // This vtable index assignment needs to be more robust, considering all inherited methods.
    new_method->vtable_index = child->method_count -1; 
}


// --- Parse Tree Node Functions ---

Node* create_node(char* type, char* value) {
    Node* node = (Node*)malloc(sizeof(Node));
    node->type = strdup(type);
    node->value = (value != NULL) ? strdup(value) : NULL;
    node->data_type = strdup("undefined");
    node->num_children = 0;
    node->children = NULL;
    node->scope_table = NULL; // Initialize scope table pointer
    return node;
}

void add_child(Node* parent, Node* child) {
    if (child == NULL) return;
    parent->num_children++;
    parent->children = (Node**)realloc(parent->children, parent->num_children * sizeof(Node*));
    parent->children[parent->num_children - 1] = child;
}

char* current_decl_type; 
%}

%union {
    char* str_val;
    struct Node* node;
}

/* Tokens */
%token <str_val> IDEN NUM STR CHR
%token <str_val> INT FLOAT CHAR VOID STRING
%token <str_val> IF ELSE WHILE FOR DO RETURN BREAK CONTINUE TR FL
%token <str_val> PASN MASN DASN SASN
%token <str_val> OR AND EQ NE LE GE LT GT
%token <str_val> INC DEC
%token <str_val> CLASS PUBLIC PRIVATE PROTECTED ABSTRACT NEW
%token MEOF

/* Precedence and Associativity */
%left OR AND
%left LT GT LE GE EQ NE
%left '+' '-'
%left '*' '/' '%'
%right '=' PASN MASN DASN SASN
%right '?' ':'
%right UMINUS INC DEC

/* Node Types */
%type <node> S STMNTS A ASNEXPR BOOLEXPR EXPR TERM TYPE LVAL
%type <node> FUNCDECL PARAMLIST PARAM DECLSTATEMENT DECLLIST DECL INITLIST INDEX
%type <node> ASSGN FUNC_CALL ARGLIST
%type <node> M NN
%type <node> CLASSDECL CLASSBODY CLASSMEMBER ACCESS CONSTRUCTOR DESTRUCTOR
%type <node> OPT_INHERIT INHERITLIST MODIFIER_DECL
%type <node> ABSTRACTCLASS ABSTRACTBODY ABSTRACTMEMBER ABSTRACTFUNC
%type <node> OPT_ASNEXPR OPT_BOOLEXPR OPT_EXPR
%type <node> OBJECTDECLSTMT OBJDECL MEMBERACCESS

%%

S: STMNTS M { $$ = create_node("PROGRAM", NULL); add_child($$, $1); root = $$; }
 |          { $$ = create_node("PROGRAM", "empty"); root = $$; }
 | error    { yyerrok; $$ = create_node("PROGRAM", "error"); root = $$; }
 ;

STMNTS: STMNTS M A { $$ = $1; if ($3 != NULL) add_child($$, $3); }
      | A M        { $$ = create_node("STATEMENTS", NULL); if ($1 != NULL) add_child($$, $1); }
      ;

A: ASNEXPR ';'                  { $$ = $1; }
 //| ASNEXPR error MEOF           { yyerrok; $$ = $1; fprintf(stderr, "Error at line %d: Malformed statement, semicolon might be missing.\n", yylineno); }
 | IF '(' BOOLEXPR ')' M A        { $$ = create_node("IF", NULL); add_child($$, $3); add_child($$, $6); }
 | IF '(' BOOLEXPR ')' M A ELSE NN M A { $$ = create_node("IF_ELSE", NULL); add_child($$, $3); add_child($$, $6); add_child($$, $10); }
 //| IF BOOLEXPR ')' M A ELSE NN M A { yyerrok; $$ = create_node("IF_ELSE_ERROR", NULL); fprintf(stderr, "Error at line %d: Missing '(' in if statement.\n", yylineno); }
 //| EXPR error MEOF              { yyerrok; $$ = $1; fprintf(stderr, "Error at line %d: Malformed expression statement.\n", yylineno); }
 | WHILE M '(' BOOLEXPR ')' M A { $$ = create_node("WHILE", NULL); add_child($$, $4); add_child($$, $7); }
// | WHILE M BOOLEXPR ')' M A     { yyerrok; $$ = create_node("WHILE_ERROR", NULL); fprintf(stderr, "Error at line %d: Missing '(' in while statement.\n", yylineno); }
 | DO { enter_scope(); } M A WHILE M '(' BOOLEXPR ')' ';' { $$ = create_node("DO_WHILE", NULL); add_child($$, $4); add_child($$, $8); $$->scope_table = current_table; exit_scope(); }
 | FOR '(' OPT_ASNEXPR ';' M OPT_BOOLEXPR ';' M OPT_EXPR ')' { enter_scope(); } M A 
   { 
     $$ = create_node("FOR", NULL);
     add_child($$, $3);
     add_child($$, $6);
     add_child($$, $9);
     add_child($$, $13);
     $$->scope_table = current_table; 
     exit_scope(); 
   }
 | '{' { enter_scope(); } STMNTS '}' { $$ = $3; $$->scope_table = current_table; exit_scope(); }
 | '{' '}'                      { $$ = create_node("BLOCK", "empty"); }
 | EXPR ';'                     { $$ = create_node("EXPR_STMT", NULL); add_child($$, $1); }
 | DECLSTATEMENT                { $$ = $1; }
 | OBJECTDECLSTMT               { $$ = $1; }
 | FUNCDECL                     { $$ = $1; }
 | CLASSDECL                    { $$ = $1; }
 | ABSTRACTCLASS                { $$ = $1; }
 | RETURN EXPR ';'              {
                                    has_return_statement = 1;
                                    $$ = create_node("RETURN", NULL); add_child($$, $2);
                                    if (current_function_return_type && !are_types_compatible(current_function_return_type, $2->data_type)) {
                                        fprintf(stderr, "Error line %d: Incompatible return type. Function expects '%s' but got '%s'.\n", yylineno, current_function_return_type, $2->data_type);
                                    }
                                }
 | RETURN ';'                   {
                                    has_return_statement = 1;
                                    $$ = create_node("RETURN", "empty");
                                    if (current_function_return_type && strcmp(current_function_return_type, "void") != 0) {
                                        fprintf(stderr, "Error line %d: Non-void function must return a value.\n", yylineno);
                                    }
                                }
 | BREAK ';'                    { $$ = create_node("BREAK", NULL); }
 | CONTINUE ';'                 { $$ = create_node("CONTINUE", NULL); }
 | ';'                          { $$ = create_node("EMPTY_STMT", NULL); }
 ;

/* FOR loop optional parts */
OPT_ASNEXPR: ASNEXPR { $$ = $1; }
           | DECLSTATEMENT { $$ = $1; }
           | /* empty */ { $$ = create_node("EMPTY_EXPR", NULL); }
           ;

OPT_BOOLEXPR: BOOLEXPR { $$ = $1; }
            | /* empty */ { $$ = create_node("EMPTY_EXPR", NULL); }
            ;

OPT_EXPR: EXPR { $$ = $1; }
        | /* empty */ { $$ = create_node("EMPTY_EXPR", NULL); }
        ;

FUNCDECL: /*TYPE IDEN '(' PARAMLIST ')' ';' {
              insert_symbol($2, $1->value, "function_prototype");
              $$ = create_node("FUNC_PROTO", $2);
              add_child($$, $1);
              add_child($$, $4);
          }
        | */TYPE IDEN '(' {
              current_function_return_type = $1->value;
              has_return_statement = 0;
              enter_scope();
              in_class_func = false;
              params = current_class_name ? 1 : 0; // Reserve slot 0 for 'this' in member functions
          } PARAMLIST ')' '{' STMNTS '}' {
              SymbolTable* func_scope = current_table;
              if (strcmp(current_function_return_type, "void") != 0 && !has_return_statement) {
                  fprintf(stderr, "Error at line %d: Missing return statement in non-void function '%s'.\n", yylineno, $2);
              }
              exit_scope();
              
              char* mangled_name = get_mangled_name($2, $5);
              insert_symbol($2, $1->value, current_class_name ? "member_func" : "function", NULL, NULL);
              //fprintf(stderr, "Debug: Function '%s' with mangled name '%s' declared.\n", $2, mangled_name);
              //fprintf(stderr, "Debug: Current class context: %s\n", current_class_name ? current_class_name : "None");
              if (current_class_info) {
                MethodInfo* method = &current_class_info->methods[current_class_info->method_count++];
                method->name = strdup($2);
                method->return_type = strdup($1->value);
                method->signature = mangled_name;
                method->vtable_index = current_class_info->method_count - 1; // Temporary, will be adjusted in check_for_override
                method->access_spec = strdup(current_access_spec);
                // TODO: Populate params
              }
              //fprintf(stderr, "Debug: Function '%s' with mangled name '%s' declared.\n", $2, mangled_name);

              $$ = create_node("FUNC_DEF", mangled_name);
              add_child($$, $1); add_child($$, $5); add_child($$, $8);
              $$->scope_table = func_scope;
              current_function_return_type = NULL;
              fprintf(stderr, "Debug: Functionend '%s' with mangled name '%s' declared.\n", $2, mangled_name);
          }
        ;

PARAMLIST: PARAM ',' PARAMLIST { $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); add_child($$, $3); }
         | PARAM               { $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); }
         |                     { $$ = create_node("PARAM_LIST", "empty"); }
         ;

PARAM: TYPE IDEN {
        insert_symbol($2, $1->value, "parameter", NULL, NULL);
        $$ = create_node("PARAM", $2); add_child($$, $1);
     }
     | TYPE IDEN INDEX {
        char* array_type = build_array_type($1->value, $3);
        insert_symbol($2, array_type, "parameter", NULL, $3);
        $$ = create_node("PARAM_ARRAY", $2); add_child($$, $1); add_child($$, $3);
        free(array_type);
     }
     | IDEN IDEN { // Object parameter
        if (!find_class_info($1)) {
            fprintf(stderr, "Error line %d: Unknown type '%s' for parameter '%s'\n", yylineno, $1, $2);
        }
        insert_symbol($2, $1, "parameter", NULL, NULL);
        $$ = create_node("PARAM", $2); add_child($$, create_node("TYPE", $1));
     }
     | IDEN IDEN INDEX { // Object array parameter
        if (!find_class_info($1)) {
            fprintf(stderr, "Error line %d: Unknown type '%s' for parameter '%s'\n", yylineno, $1, $2);
        }
        char* array_type = build_array_type($1, $3);
        insert_symbol($2, array_type, "parameter", NULL, $3);
        $$ = create_node("PARAM_ARRAY", $2); add_child($$, create_node("TYPE", $1)); add_child($$, $3);
        free(array_type);
     }
     ;

DECLSTATEMENT: TYPE DECLLIST ';' {
                 $$ = create_node("DECL_STMT", NULL);
                 add_child($$, $1); add_child($$, $2);
               }
               //  | TYPE DECLLIST error  { 
            //      yyerrok; 
            //      $$ = create_node("DECL_STMT_ERROR", NULL);
            //      add_child($$, $1);
            //      add_child($$, $2);
            //      fprintf(stderr, "Error at line %d: Malformed declaration, likely missing semicolon.\n", yylineno);
            //    }
            
             ;

DECLLIST: DECL ',' DECLLIST { $$ = $3; add_child($$, $1); }
        | DECL              { $$ = create_node("DECL_LIST", NULL); add_child($$, $1); }
        ;
DECL: IDEN {
        insert_symbol($1, current_decl_type, current_class_name && in_class_func ? "member_var" : "variable", NULL, NULL);
        $$ = create_node("VAR_DECL", $1);
      }
    | IDEN '=' EXPR {
        if (!are_types_compatible(current_decl_type, $3->data_type)) {
            fprintf(stderr, "Error line %d: Incompatible types in initialization. Cannot assign '%s' to '%s'\n", yylineno, $3->data_type, current_decl_type);
        }
        insert_symbol($1, current_decl_type, current_class_name && in_class_func ? "member_var" : "variable", $3, NULL);
        $$ = create_node("VAR_INIT", $1); 
        add_child($$, $3);
      }
    | IDEN INDEX {
        char* array_type = build_array_type(current_decl_type, $2);
        insert_symbol($1, array_type, current_class_name && in_class_func ? "member_var" : "variable", NULL, $2);
        $$ = create_node("ARRAY_DECL", $1); 
        add_child($$, $2);
        free(array_type);
      }
    | IDEN INDEX '=' '{' INITLIST '}' {
        char* array_type = build_array_type(current_decl_type, $2);
        insert_symbol($1, array_type, current_class_name && in_class_func ? "member_var" : "variable", $5, $2);
        check_init_list_types($5, current_decl_type);
        $$ = create_node("ARRAY_INIT", $1); 
        add_child($$, $2); 
        add_child($$, $5);
        free(array_type);
      }
    ;
INITLIST: INITLIST ',' EXPR { $$ = $1; add_child($$, $3); }
        | EXPR              { $$ = create_node("INIT_LIST", NULL); add_child($$, $1); }
        ;
INDEX: '[' EXPR ']' { $$ = create_node("INDEX", NULL); add_child($$, $2); if (strcmp($2->data_type, "int") != 0) { fprintf(stderr, "Error line %d: Array index must be an integer (got '%s')\n", yylineno, $2->data_type); } }
     | '[' EXPR ']' INDEX { $$ = create_node("INDEX", NULL); add_child($$, $2); add_child($$, $4); if (strcmp($2->data_type, "int") != 0) { fprintf(stderr, "Error line %d: Array index must be an integer (got '%s')\n", yylineno, $2->data_type); } }
     ;
TYPE: INT    { current_decl_type = "int"; $$ = create_node("TYPE", "int"); }
    | FLOAT  { current_decl_type = "float"; $$ = create_node("TYPE", "float"); }
    | CHAR   { current_decl_type = "char"; $$ = create_node("TYPE", "char"); }
    | VOID   { current_decl_type = "void"; $$ = create_node("TYPE", "void"); }
    | STRING { current_decl_type = "string"; $$ = create_node("TYPE", "string"); }
    ;
ASSGN: '='  { $$ = create_node("ASSIGN_OP", "="); }
     | PASN { $$ = create_node("ASSIGN_OP", "+="); }
     | MASN { $$ = create_node("ASSIGN_OP", "-="); }
     | DASN { $$ = create_node("ASSIGN_OP", "/="); }
     | SASN { $$ = create_node("ASSIGN_OP", "*="); }
     ;
LVAL: IDEN {
        Symbol* s = lookup_symbol($1);
        if (!s) {
            fprintf(stderr, "Error line %d: Variable '%s' not defined\n", yylineno, $1);
            $$ = create_node("IDEN", $1);
            $$->data_type = strdup("undefined");
        } else {
            $$ = create_node("IDEN", $1);
            $$->data_type = strdup(s->type);
        }
      }
    | IDEN INDEX {
        $$ = create_node("ARRAY_ACCESS", $1);
        add_child($$, $2);
        Symbol* s = lookup_symbol($1);
        if (!s) {
            fprintf(stderr, "Error line %d: Array '%s' not defined\n", yylineno, $1);
            $$->data_type = strdup("undefined");
        } else {
            // Traverse the type string to find the element type
            char* type = strdup(s->type);
            Node* temp_idx = $2;
            while(temp_idx) {
                if(strncmp(type, "[", 1) == 0) {
                    char* inner = strdup(type + 1); // Skip the leading '['
                    inner[strlen(inner)-1] = '\0';
                    free(type);
                    type = inner;
                } else {
                     fprintf(stderr, "Error line %d: Invalid indexing on non-array type for '%s'\n", yylineno, $1);
                     free(type);
                     type = strdup("undefined");
                     break;
                }
                temp_idx = (temp_idx->num_children == 2) ? temp_idx->children[1] : NULL;
            }
            $$->data_type = type;
        }
      }
    | MEMBERACCESS { $$ = $1; }
    ;
ASNEXPR: LVAL ASSGN EXPR {
           if (!are_types_compatible($1->data_type, $3->data_type)) {
               fprintf(stderr, "Error line %d: Type mismatch in assignment. Cannot assign '%s' to '%s'\n", yylineno, $3->data_type, $1->data_type);
           }
           $$ = create_node("ASSIGN", NULL);
           add_child($$, $1); add_child($$, $2); add_child($$, $3);
         }
        | LVAL '=' NEW IDEN '(' ARGLIST ')'
        {
            ClassInfo* cls_info = find_class_info($4);
            if (cls_info && cls_info->is_abstract) {
                fprintf(stderr, "Error line %d: Cannot create an instance of abstract class '%s'\n", yylineno, $4);
            }
            $$ = create_node("NEW_OBJ_ASSIGN", NULL);
            add_child($$, $1);
            Node* new_node = create_node("NEW_OBJ", $4);
            add_child(new_node, $6);
            add_child($$, new_node);
        }
       ;
BOOLEXPR: BOOLEXPR OR M BOOLEXPR   { $$ = create_node("BOOL_OP", "||"); add_child($$, $1); add_child($$, $4); $$->data_type=strdup("bool"); }
        | BOOLEXPR AND M BOOLEXPR  { $$ = create_node("BOOL_OP", "&&"); add_child($$, $1); add_child($$, $4); $$->data_type=strdup("bool"); }
        | '!' '(' BOOLEXPR ')'     { $$ = create_node("BOOL_OP", "!"); add_child($$, $3); $$->data_type=strdup("bool"); }
        | '(' BOOLEXPR ')'         { $$ = $2; }
        | EXPR LT EXPR             { $$ = create_node("REL_OP", "<"); add_child($$, $1); add_child($$, $3); $$->data_type=strdup("bool"); }
        | EXPR GT EXPR             { $$ = create_node("REL_OP", ">"); add_child($$, $1); add_child($$, $3); $$->data_type=strdup("bool"); }
        | EXPR EQ EXPR             { $$ = create_node("REL_OP", "=="); add_child($$, $1); add_child($$, $3); $$->data_type=strdup("bool"); }
        | EXPR NE EXPR             { $$ = create_node("REL_OP", "!="); add_child($$, $1); add_child($$, $3); $$->data_type=strdup("bool"); }
        | EXPR LE EXPR             { $$ = create_node("REL_OP", "<="); add_child($$, $1); add_child($$, $3); $$->data_type=strdup("bool"); }
        | EXPR GE EXPR             { $$ = create_node("REL_OP", ">="); add_child($$, $1); add_child($$, $3); $$->data_type=strdup("bool"); }
        | TR                       { $$ = create_node("BOOL_CONST", "true"); $$->data_type=strdup("bool"); }
        | FL                       { $$ = create_node("BOOL_CONST", "false"); $$->data_type=strdup("bool"); }
        ;
EXPR: EXPR '+' EXPR { $$ = create_node("BIN_OP", "+"); add_child($$, $1); add_child($$, $3); $$->data_type = strdup(get_promoted_type($1->data_type, $3->data_type)); }
    | EXPR '-' EXPR { $$ = create_node("BIN_OP", "-"); add_child($$, $1); add_child($$, $3); $$->data_type = strdup(get_promoted_type($1->data_type, $3->data_type)); }
    | EXPR '*' EXPR { $$ = create_node("BIN_OP", "*"); add_child($$, $1); add_child($$, $3); $$->data_type = strdup(get_promoted_type($1->data_type, $3->data_type)); }
    | EXPR '/' EXPR { $$ = create_node("BIN_OP", "/"); add_child($$, $1); add_child($$, $3); $$->data_type = strdup(get_promoted_type($1->data_type, $3->data_type)); }
    | EXPR '%' EXPR { $$ = create_node("BIN_OP", "%"); add_child($$, $1); add_child($$, $3); $$->data_type = strdup("int"); }
    | BOOLEXPR '?' EXPR ':' EXPR { $$ = create_node("TERNARY_OP", NULL); add_child($$, $1); add_child($$, $3); add_child($$, $5); $$->data_type = strdup($3->data_type); }
    | FUNC_CALL     { $$ = $1; }
    | TERM          { $$ = $1; }
    | '-' EXPR %prec UMINUS { $$ = create_node("UN_OP", "-"); add_child($$, $2); $$->data_type = strdup($2->data_type); }
    ;
FUNC_CALL: IDEN '(' ARGLIST ')' {
            Symbol* s = lookup_symbol($1);
            // if(!s || (strcmp(s->type, "function") != 0 && strcmp(s->type, "member_func") != 0)) {
            //      fprintf(stderr, "Error line %d: '%s' is not a function or is not defined. %s\n", yylineno, $1, s ? s->type : "undefined");
            //      // print s
            //         if(s) {
            //             fprintf(stderr, "Debug: Symbol '%s' found with type '%s'\n", s->name, s->type);
            //         } else {
            //             fprintf(stderr, "Debug: Symbol '%s' not found in symbol table\n", $1);
            //         }
            // }
            char* mangled_name = get_mangled_name($1, $3);
            $$ = create_node("FUNC_CALL", mangled_name);
            add_child($$, $3);
            $$->data_type = s ? strdup(s->type) : strdup("undefined");
         }
         ;
ARGLIST: EXPR ',' ARGLIST { $$ = $3; add_child($$, $1); }
       | EXPR            { $$ = create_node("ARG_LIST", NULL); add_child($$, $1); }
       |                 { $$ = create_node("ARG_LIST", "empty"); }
       ;
TERM: LVAL { $$ = $1; }
    | NUM  { $$ = create_node("NUM", $1); $$->data_type = (strchr($1, '.')) ? strdup("float") : strdup("int"); }
    | STR  { $$ = create_node("STRING_LIT", $1); $$->data_type = strdup("string"); }
    | CHR  { $$ = create_node("CHAR_LIT", $1); $$->data_type = strdup("char"); }
    // | TR   { $$ = create_node("BOOL_CONST", "true"); $$->data_type="bool"; }
    // | FL   { $$ = create_node("BOOL_CONST", "false"); $$->data_type="bool"; }
    | '(' EXPR ')' { $$ = $2; }
    | LVAL INC { $$ = create_node("POST_INC", "++"); add_child($$, $1); $$->data_type = strdup($1->data_type); }
    | LVAL DEC { $$ = create_node("POST_DEC", "--"); add_child($$, $1); $$->data_type = strdup($1->data_type); }
    | INC LVAL { $$ = create_node("PRE_INC", "++"); add_child($$, $2); $$->data_type = strdup($2->data_type); }
    | DEC LVAL { $$ = create_node("PRE_DEC", "--"); add_child($$, $2); $$->data_type = strdup($2->data_type); }
    ;
CLASSDECL: CLASS IDEN {
                current_class_name = $2;
                current_class_info = (ClassInfo*)calloc(1, sizeof(ClassInfo));
                current_class_info->name = strdup($2);
                class_metadata_pool[class_pool_count++] = current_class_info;
                current_class_info->constructors_count = 0;
                current_table->base_count++; // Reserve space for 'this' object
                local_address_counter++; // Adjust local address counter
                enter_scope();
                current_class_info->symbol_table = current_table;
           } OPT_INHERIT '{' CLASSBODY '}' ';' {
            perform_diamond_check(current_class_info);
            check_abstract_implementation(current_class_info);
            $$ = create_node("CLASS_DECL", $2);
            add_child($$, $4); add_child($$, $6);
            // Default Constructor(To be handled)
            // if (current_class_info && current_class_info->constructors_count == 0) {
            //     fprintf(stderr, "Debug: No constructor found for '%s'. Synthesizing a default constructor node.\n", current_class_info->name);

            //     // 1. Create MethodInfo (same as before)
            //     MethodInfo* method = &current_class_info->methods[current_class_info->method_count++];
            //     method->name = strdup(current_class_info->name);
            //     method->return_type = strdup("void");
            //     method->signature = strdup(current_class_info->name);
            //     method->access_spec = strdup("public");
            //     method->is_abstract = false;
            //     method->is_override = false;
            //     method->vtable_index = current_class_info->method_count - 1;

            //     // 2. Create a new CONSTRUCTOR node for the AST
            //     Node* constructor_node = create_node("CONSTRUCTOR", current_class_info->name);
                
            //     // Create empty nodes for its children (param list and body)
            //     Node* empty_params = create_node("PARAM_LIST", "empty");
            //     Node* empty_body = create_node("STATEMENTS", "empty");

            //     add_child(constructor_node, empty_params);
            //     add_child(constructor_node, empty_body);

            //     // 3. Add the new node to the class body in the AST
            //     // $6 is the CLASSBODY node from the grammar rule
            //     add_child($6, constructor_node);
            // }
            $$->scope_table = current_table;
            exit_scope();
            current_table->base_count--; // Release 'this' space
            local_address_counter--; // Adjust local address counter
            current_class_name = NULL;
            current_class_info = NULL;
           };
OPT_INHERIT: ':' INHERITLIST { $$ = $2; }
           | /* empty */ { $$ = create_node("NO_INHERITANCE", NULL); }
           ;
INHERITLIST: ACCESS IDEN {
                if (current_class_info && current_class_info->parent_count < MAX_PARENTS) {
                    current_class_info->parent_names[current_class_info->parent_count++] = strdup($2);
                }
                $$ = create_node("INHERIT_LIST", NULL);
             }
           | ACCESS IDEN ',' INHERITLIST {
                if (current_class_info && current_class_info->parent_count < MAX_PARENTS) {
                    current_class_info->parent_names[current_class_info->parent_count++] = strdup($2);
                }
                $$ = $4;
             }
           ;
CLASSBODY: CLASSBODY CLASSMEMBER { $$ = $1; add_child($$, $2); }
         | CLASSMEMBER           { $$ = create_node("CLASS_BODY", NULL); add_child($$, $1); }
         | /* empty */           { $$ = create_node("CLASS_BODY", "empty"); }
         ;
CLASSMEMBER: ACCESS  MODIFIER_DECL { $$ = $2; in_class_func = false; }
           | ACCESS  FUNCDECL { $$ = $2; in_class_func = false; }
           | ACCESS  ABSTRACTFUNC { $$ = $2; in_class_func = false;}
           | ACCESS  CONSTRUCTOR { $$ = $2; in_class_func = false; }
           | ACCESS  DESTRUCTOR { $$ = $2; in_class_func = false; }
           | ACCESS  ABSTRACTMEMBER { $$ = $2; in_class_func = false; }
           | ACCESS  OBJECTDECLSTMT { $$ = $2; in_class_func = false;}
           ;
ACCESS: PUBLIC    { $$ = create_node("ACCESS", "public"); current_access_spec = "public"; in_class_func = true; }
      | PRIVATE   { $$ = create_node("ACCESS", "private"); current_access_spec = "private"; in_class_func = true; }
      | PROTECTED { $$ = create_node("ACCESS", "protected"); current_access_spec = "protected"; in_class_func = true; }
      //     | /* empty */ { $$ = create_node("ACCESS", "private"); /* Default access */ }
      ;
MODIFIER_DECL: TYPE DECLLIST ';' { 
               $$ = create_node("MEMBER_DECL", NULL); 
               add_child($$, $1); 
               add_child($$, $2); 
            }
              ;
CONSTRUCTOR: IDEN '(' { 
                enter_scope();
                if (!current_class_name || strcmp($1, current_class_name) != 0) {
                    fprintf(stderr, "Error line %d: Constructor name '%s' does not match class name '%s'\n", yylineno, $1, current_class_name ? current_class_name : "None");
                }
            } PARAMLIST ')' {in_class_func = false;} '{' STMNTS '}' ';' {
                exit_scope();
                char* mangled_name = get_mangled_name($1, $4);
                insert_symbol($1, "constructor", "member_func", NULL, NULL);
                current_class_info->constructors_count++;
                if (current_class_info) {
                    MethodInfo* method = &current_class_info->methods[current_class_info->method_count++];
                    method->name = strdup($1);
                    method->return_type = strdup("void");
                    method->signature = mangled_name;
                    method->vtable_index = current_class_info->method_count - 1; // Constructors do not go in vtable
                    method->access_spec = strdup(current_access_spec);
                    fprintf(stderr, "---------------Debug: Constructor index for '%s': %d\n", $1, method->vtable_index);
                }

                fprintf(stderr, "---------------Debug: Constructor signature for '%s': %s\n", $1, mangled_name);
                
                $$ = create_node("CONSTRUCTOR", $1);
                add_child($$, $4); add_child($$, $8);
                $$->scope_table = current_table;
             }
             ;
DESTRUCTOR: '~' IDEN '(' ')' {in_class_func = false;} '{' STMNTS '}' ';' { $$ = create_node("DESTRUCTOR", $2); add_child($$, $7); }
            ;
ABSTRACTCLASS: ABSTRACT CLASS IDEN {
                 current_class_name = $3;
                 current_class_info = (ClassInfo*)calloc(1, sizeof(ClassInfo));
                 current_class_info->name = strdup($3);
                 current_class_info->is_abstract = true; // Set the flag immediately
                 class_metadata_pool[class_pool_count++] = current_class_info;
                 current_class_info->constructors_count = 0;
                 enter_scope();
                 current_class_info->symbol_table = current_table;
             } OPT_INHERIT '{' ABSTRACTBODY '}' ';' {
                 perform_diamond_check(current_class_info);
                 $$ = create_node("ABSTRACT_CLASS", $3);
                 add_child($$, $5); // OPT_INHERIT
                 add_child($$, $7); // ABSTRACTBODY
                 $$->scope_table = current_table;
                 exit_scope();
                 current_class_name = NULL;
                 current_class_info = NULL;
             }
             ;
ABSTRACTBODY: ABSTRACTBODY ABSTRACTMEMBER { $$ = $1; add_child($$, $2); }
            | ABSTRACTMEMBER             { $$ = create_node("ABSTRACT_BODY", NULL); add_child($$, $1); }
            ;
ABSTRACTMEMBER: ACCESS ABSTRACTFUNC { $$ = $2; }
              ;
ABSTRACTFUNC: ABSTRACT TYPE IDEN '(' PARAMLIST ')' ';' {
                if (current_class_info) {
                    MethodInfo* method = &current_class_info->methods[current_class_info->method_count++];
                    method->name = strdup($3);
                    method->return_type = strdup($2->value);
                    method->signature = get_mangled_name($3, $5);
                    method->access_spec = strdup(current_access_spec);
                    method->is_abstract = true; // Set the abstract flag
                    method->is_override = false; // Override check can be done later
                    method->vtable_index = -1; // V-table index is for concrete methods
                }
                $$ = create_node("ABSTRACT_FUNC", $3); add_child($$, $2); add_child($$, $5); 
            }
              ;
OBJECTDECLSTMT: OBJDECL ';' { $$ = $1; }
               ;
OBJDECL: IDEN IDEN { 
            insert_symbol($2, $1, current_class_name && in_class_func ? "member_obj" : "object", NULL, NULL);
            $$ = create_node("OBJ_DECL", $2);
            $$->data_type = strdup($1);
        }
        | IDEN IDEN '=' NEW IDEN '(' ARGLIST ')' { 
            ClassInfo* cls_info = find_class_info($1);
            if( cls_info && cls_info->is_abstract ) {
                fprintf(stderr, "Error line %d: Cannot instantiate abstract class '%s'\n", yylineno, $1);
            } else if (!cls_info) {
                fprintf(stderr, "Error line %d: Unknown class type '%s' for object '%s'\n", yylineno, $1, $2);
            }
            insert_symbol($2, $1, current_class_name && in_class_func ? "member_obj" : "object", NULL, NULL); // Initializer handled by ASNEXPR
            $$ = create_node("OBJ_INIT", $2); 
            add_child($$, $7); 
            $$->data_type = strdup($1);
        }
        | IDEN IDEN INDEX { 
            char* array_type = build_array_type($1, $3);
            insert_symbol($2, array_type, current_class_name && in_class_func ? "member_obj" : "object", NULL, $3);
            $$ = create_node("OBJ_ARRAY_DECL", $2);
            add_child($$, $3);
            $$->data_type = array_type;
        }
         ;
MEMBERACCESS: LVAL '.' IDEN { 
                $$ = create_node("MEMBER_VAR_ACCESS", $3);
                add_child($$, $1);
                ClassInfo* cls_info = find_class_info($1->data_type);
                if(!cls_info) {
                    fprintf(stderr, "Error line %d: Member access on non-class type '%s'\n", yylineno, $1->data_type);
                    $$->data_type = strdup("undefined");
                } else {
                    FieldInfo* field = find_field_in_hierarchy($3, cls_info);
                    if(!field) {
                         fprintf(stderr, "Error line %d: Class '%s' has no member named '%s'\n", yylineno, cls_info->name, $3);
                         $$->data_type = strdup("undefined");
                    } else {
                        $$->data_type = strdup(field->type);
                    }
                }
            }
            | LVAL '.' IDEN INDEX {
               // Similar logic to MEMBER_VAR_ACCESS but for arrays
               $$ = create_node("MEMBER_ARRAY_ACCESS", $3);
               add_child($$, $1); add_child($$, $4);
               ClassInfo* cls_info = find_class_info($1->data_type);
               if(!cls_info) {
                fprintf(stderr, "Error line %d: Member access on non-class type '%s'\n", yylineno, $1->data_type);
                $$->data_type = strdup("undefined");
               } else {
                   FieldInfo* field = find_field_in_hierarchy($3, cls_info);
                   if(!field) {
                        fprintf(stderr, "Error line %d: Class '%s' has no member named '%s'\n", yylineno, cls_info->name, $3);
                        $$->data_type = strdup("undefined");
                   } else {
                       // Traverse the type string to find the element type
                       char* type = strdup(field->type);
                       Node* temp_idx = $4;
                       while(temp_idx) {
                           if(strncmp(type, "[", 1) == 0) {
                               char* inner = strdup(type + 1);
                               inner[strlen(inner)-1] = '\0';
                               type = inner;
                           } else {
                                fprintf(stderr, "Error line %d: Invalid indexing on non-array type for member '%s'\n", yylineno, $3);
                                type = strdup("undefined");
                                break;
                           }
                           temp_idx = (temp_idx->num_children == 2) ? temp_idx->children[1] : NULL;
                       }
                       $$->data_type = type;
                   }
               }
            }
            | LVAL '.' FUNC_CALL {
               $$ = create_node("MEMBER_FUNC_ACCESS", NULL);
               add_child($$, $1); add_child($$, $3);
               ClassInfo* cls_info = find_class_info($1->data_type);
               if(!cls_info) {
                   fprintf(stderr, "Error line %d: Method call on non-class type '%s'\n", yylineno, $1->data_type);
                   $$->data_type = strdup("undefined");
               } else {
                   MethodInfo* method = find_method_in_hierarchy(NULL, $3->value, cls_info);
                   if(!method) {
                        fprintf(stderr, "Error line %d: Class '%s' has no method with signature '%s'\n", yylineno, cls_info->name, $3->value);
                        $$->data_type = strdup("undefined");
                   } else {
                       $$->data_type = strdup(method->return_type);
                   }
               }
            }
           ;

/* --- End OOP Grammar --- */


/* Markers */
M:  { $$ = NULL; }
NN: { $$ = NULL; }


%%

// --- Code Generation ---

FILE* asm_file;
int label_count = 0;
int code_gen_depth = 0; 
char* string_pool[256];
int string_pool_count = 0;
char* array_descriptor_pool[256];
int array_descriptor_count = 0;
int loop_break_labels[MAX_LOOP_DEPTH];
int loop_continue_labels[MAX_LOOP_DEPTH];
int loop_stack_ptr = -1; // Acts as a stack pointer for the loop labels

void generate_code_for_expr(Node* node, SymbolTable* scope, ClassInfo* class_context); // Forward declare
void generate_code_for_lval(Node* node, SymbolTable* scope, bool for_storing);



int get_array_descriptor_index(char* descriptor) {
    for (int i = 0; i < array_descriptor_count; i++) {
        if (strcmp(array_descriptor_pool[i], descriptor) == 0) {
            return i;
        }
    }
    if (array_descriptor_count < 256) {
        array_descriptor_pool[array_descriptor_count] = strdup(descriptor);
        return array_descriptor_count++;
    }
    fprintf(stderr, "Error: Array descriptor pool overflow.\n");
    return -1;
}

// --- Codegen Helper Functions ---
int calculate_total_locals(SymbolTable* func_scope) {
    int max_addr = -1;
    // This function needs to iterate through all symbol tables that are descendants
    // of the function's root scope to find the highest address.
    // A simple count of the immediate scope is often sufficient if scopes aren't deeply nested.
    for (int i = 0; i < table_count; i++) {
        SymbolTable* current = all_tables[i];
        bool is_descendant = false;
        SymbolTable* temp = current;
        while(temp != NULL) {
            if (temp == func_scope) {
                is_descendant = true;
                break;
            }
            temp = temp->parent;
        }

        if(is_descendant) {
             for (int j = 0; j < current->count; j++) {
                Symbol* s = current->symbols[j];
                if ((strcmp(s->kind, "variable") == 0 || strcmp(s->kind, "object") == 0 || strcmp(s->kind, "parameter") == 0) && s->address > max_addr) {
                    max_addr = s->address;
                }
            }
        }
    }
    return max_addr + 1;
}

int calculate_max_stack_depth(Node* node) {
    if (!node) return 0;

    int max_child_depth = 0;
    for (int i = 0; i < node->num_children; i++) {
        int child_depth = calculate_max_stack_depth(node->children[i]);
        if (child_depth > max_child_depth) {
            max_child_depth = child_depth;
        }
    }

    if (strcmp(node->type, "BIN_OP") == 0) {
        int left_depth = calculate_max_stack_depth(node->children[0]);
        int right_depth = calculate_max_stack_depth(node->children[1]);
        return (left_depth > right_depth + 1) ? left_depth : right_depth + 1;
    }
    if (strcmp(node->type, "FUNC_CALL") == 0 || strcmp(node->type, "MEMBER_FUNC_ACCESS") == 0) {
        int max_arg_depth = 0;
        Node* arg_list = (strcmp(node->type, "FUNC_CALL") == 0) ? node->children[0] : node->children[1]->children[0];
        for (int i = 0; i < arg_list->num_children; i++) {
             int arg_depth = calculate_max_stack_depth(arg_list->children[i]) + i;
             if(arg_depth > max_arg_depth) max_arg_depth = arg_depth;
        }
        return max_arg_depth + 1; // +1 for the object reference in member calls
    }
    if (strcmp(node->type, "NUM") == 0 || strcmp(node->type, "IDEN") == 0 || strcmp(node->type, "STRING_LIT") == 0 || strcmp(node->type, "CHAR_LIT") == 0) {
        return 1;
    }
    
    return max_child_depth;
}


void debug_print(const char* format, ...) {
    for(int i = 0; i < code_gen_depth; ++i) fprintf(stderr, "  ");
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fprintf(stderr, "\n");
}


void emit(const char* format, ...) {
    va_list args;
    va_start(args, format);
    vfprintf(asm_file, format, args);
    va_end(args);
    fprintf(asm_file, "\n");
}

int new_label() { return label_count++; }

int get_string_label_index(char* literal) {
    char* content = strdup(literal + 1);
    content[strlen(content) - 1] = '\0'; // Remove quotes

    for (int i = 0; i < string_pool_count; i++) {
        if (strcmp(string_pool[i], content) == 0) {
            free(content);
            return i;
        }
    }
    if (string_pool_count < 256) {
        string_pool[string_pool_count] = content;
        return string_pool_count++;
    }
    free(content);
    fprintf(stderr, "Error: String pool overflow.\n");
    return -1;
}

// New lookup function for code generation that includes class hierarchy search.
Symbol* lookup_symbol_codegen(char* name, SymbolTable* scope, ClassInfo* class_context) {
    // Step 1: Search local and enclosing lexical scopes.
    SymbolTable* table = scope;
    while (table != NULL) {
        for (int i = 0; i < table->count; i++) {
            if (strcmp(table->symbols[i]->name, name) == 0) {
                return table->symbols[i];
            }
        }
        table = table->parent;
    }

    // Step 2: If not found lexically and we are in a class context, search the inheritance hierarchy.
    if (class_context != NULL) {
        return lookup_in_class_hierarchy(name, class_context);
    }
    
    return NULL;
}

// TODO (Default constructor field initialization code generation)
// void generate_field_initialization_code(ClassInfo* class_info, SymbolTable* class_scope) {
//     if (class_info == NULL) {
//         return;
//     }

//     // First, recursively initialize fields from parent classes.
//     for (int i = 0; i < class_info->parent_count; i++) {
//         // A class's scope is stored with its metadata.
//         generate_field_initialization_code(class_info->parents[i], class_info->parents[i]->symbol_table);
//     }

//     // Now, initialize fields declared in the current class.
//     for (int i = 0; i < class_info->field_count; i++) {
//         FieldInfo* field = &class_info->fields[i];
//         int field_idx = get_field_index(class_info->name, field->name);

//         if (field_idx != -1) {
//             emit("LOAD 0      ; Push 'this' reference for field '%s'", field->name);

//             if (field->initializer != NULL) {
//                 // Case 1: An initializer like '= 5' was provided.
//                 // Generate code to evaluate the expression.
//                 generate_code_for_expr(field->initializer, class_scope, class_info);
//             } else {
//                 // Case 2: No initializer was provided. Default to 0 or null.
//                 emit("PUSH 0      ; Default value for '%s'", field->name);
//             }
//             emit("PUTFIELD %d ; this.%s = ...", field_idx, field->name);
//         }
//     }
// }

// Helper function to extract the base type from a mangled array type string
char* get_base_array_type(const char* mangled_type) {
    if (mangled_type == NULL || mangled_type[0] != '[') {
        return strdup(mangled_type); // Not an array
    }
    // Find the character following the last '['
    const char* last_bracket = strrchr(mangled_type, '[');
    char type_char = *(last_bracket + 1);
    switch (type_char) {
        case 'I': return strdup("int");
        case 'F': return strdup("float");
        case 'C': return strdup("char");
        case 'L': { // Object type like LMyClass;
            char* base_type = strdup(last_bracket + 2); // Skip 'L'
            char* semicolon = strchr(base_type, ';');
            if (semicolon) *semicolon = '\0'; // Remove trailing ';'
            return base_type;
        }
        default: return strdup("unknown");
    }
}



void generate_code_for_boolean_expr(Node* node, int true_label, int false_label, SymbolTable* scope, ClassInfo* class_context) {
    if (!node) return;
    debug_print("Gen BOOL EXPR for: %s (%s)", node->type, node->value ? node->value : "");
    code_gen_depth++;

    if (strcmp(node->type, "REL_OP") == 0) {
        generate_code_for_expr(node->children[0], scope, class_context);
        generate_code_for_expr(node->children[1], scope, class_context);
        if (strcmp(node->value, "<") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_LT");
        else if (strcmp(node->value, "<") == 0) emit("ICMP_LT");
        else if (strcmp(node->value, "<=") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_LE");
        else if (strcmp(node->value, "<=") == 0) emit("ICMP_LE");
        else if (strcmp(node->value, "!=") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_NEQ");
        else if (strcmp(node->value, "!=") == 0) emit("ICMP_NEQ");
        else if (strcmp(node->value, ">=") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_GE");
        else if (strcmp(node->value, ">=") == 0) emit("ICMP_GE");        else if (strcmp(node->value, "==") == 0) emit("ICMP_EQ");
        else if (strcmp(node->value, "==") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_EQ");
        else if (strcmp(node->value, "==") == 0) emit("ICMP_EQ");
        else if (strcmp(node->value, ">") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_GT");
        else if (strcmp(node->value, ">") == 0) emit("ICMP_GT");
        else {
            fprintf(stderr, "Codegen Error: Unsupported relational operator '%s'\n", node->value);
            return;
        }
        emit("JNZ L%d", true_label);
        emit("JMP L%d", false_label);
    } else if (strcmp(node->type, "BOOL_CONST") == 0) {
        if (strcmp(node->value, "true") == 0) {
            emit("JMP L%d", true_label);
        } else {
            emit("JMP L%d", false_label);
        }
    } else if (strcmp(node->type, "BOOL_OP") == 0) {
        if (strcmp(node->value, "&&") == 0) {
            int next_cond_label = new_label();
            generate_code_for_boolean_expr(node->children[0], next_cond_label, false_label, scope, class_context);
            fprintf(asm_file, "L%d:\n", next_cond_label);
            generate_code_for_boolean_expr(node->children[1], true_label, false_label, scope, class_context);
        } else if (strcmp(node->value, "||") == 0) {
            int next_cond_label = new_label();
            generate_code_for_boolean_expr(node->children[0], true_label, next_cond_label, scope, class_context);
            fprintf(asm_file, "L%d:\n", next_cond_label);
            generate_code_for_boolean_expr(node->children[1], true_label, false_label, scope, class_context);
        }
    } else { 
        generate_code_for_expr(node, scope, class_context);
        emit("JNZ L%d", true_label);
        emit("JMP L%d", false_label);
    }
    code_gen_depth--;
}


// Generates code to get the address of an L-value on the stack.
// For arrays: pushes array_ref, then index.
// For members: pushes object_ref.
void generate_code_for_lval_address(Node* node, SymbolTable* scope, ClassInfo* class_context) {
    if (!node) return;
    debug_print("Gen LVAL ADDR for: %s (%s)", node->type, node->value ? node->value : "");
    code_gen_depth++;
    
    if (strcmp(node->type, "IDEN") == 0) {
        // The "address" is just the symbol's index, handled by LOAD/STORE.
        // No code emitted here.
    } else if (strcmp(node->type, "ARRAY_ACCESS") == 0) {
        //fprintf(stderr, "Generating code for array access L-value: %s\n", node->value);
        Symbol* s = lookup_symbol_codegen(node->value, scope, class_context);
        if (!s || !s->dimension_info) {  
            fprintf(stderr, "Codegen Error: Array '%s' not found.\n", node->value);
            return; 
        }

        // Push the base array reference onto the stack
        if (s->class_name) {
            emit("LOAD 0 ; Load 'this' to access member array '%s'", s->name);
            int field_idx = get_field_index(s->class_name, s->name);
            emit("GETFIELD %d", field_idx);
        } else {
            // Local variable or parameter
            emit("LOAD %d ; Load base array ref '%s'", s->address, s->name);
        }

        Node* access_idx_list = node->children[0];
        Node* decl_dim_list = s->dimension_info > 1 ? s->dimension_info->children[1] : NULL;

        // First index
        generate_code_for_expr(access_idx_list->children[0], scope, class_context);

        while (decl_dim_list) {
            // Multiply by the size of the next dimension
            generate_code_for_expr(decl_dim_list->children[0], scope, class_context);
            emit("IMUL");
            // Move to the next index in access list
            access_idx_list = access_idx_list->num_children > 1 ? access_idx_list->children[1] : NULL;
            if (access_idx_list) {
                generate_code_for_expr(access_idx_list->children[0], scope, class_context);
                emit("IADD");
            } else {
                break;
            }
            // Move to the next dimension in declaration list
            decl_dim_list = decl_dim_list->num_children > 1 ? decl_dim_list->children[1] : NULL;
        }

    } else if (strcmp(node->type, "MEMBER_VAR_ACCESS") == 0) {
        // Push the object reference onto the stack
        generate_code_for_expr(node->children[0], scope, class_context);
    } else if (strcmp(node->type, "MEMBER_ARRAY_ACCESS") == 0) {
        // Push the object reference and then the index
        generate_code_for_expr(node->children[0], scope, class_context);
        emit("GETFIELD %d ; Get field '%s'", get_field_index(node->children[0]->data_type, node->value), node->value);

        // Calculate flattened index
        FieldInfo* field = find_field_in_hierarchy(node->value, find_class_info(node->children[0]->data_type));
        if (!field) {
            fprintf(stderr, "Codegen Error: Array field '%s' not found or is not an array.\n", node->value);
            return;
        }

        Node* access_idx_list = node->children[1];
        Node* decl_dim_list = field->initializer->num_children > 1 ? field->initializer->children[1] : NULL;

        generate_code_for_expr(access_idx_list->children[0], scope, class_context);
        
        while (decl_dim_list) {
            generate_code_for_expr(decl_dim_list->children[0], scope, class_context);
            emit("IMUL");
            access_idx_list = access_idx_list->children[1];
            if (access_idx_list) {
                generate_code_for_expr(access_idx_list->children[0], scope, class_context);
                emit("IADD");
            } else {
                break;
            }
            decl_dim_list = decl_dim_list->num_children > 1 ? decl_dim_list->children[1] : NULL;
        }
        
    } else {
        fprintf(stderr, "Codegen Error: Unsupported L-value type '%s'\n", node->type);
    }
    code_gen_depth--;
}

void generate_code_for_expr(Node* node, SymbolTable* scope, ClassInfo* class_context) {
    if (!node) return;
    debug_print("Gen EXPR for: %s (%s)", node->type, node->value ? node->value : "");
    code_gen_depth++;

    if (strcmp(node->type, "NUM") == 0 && strcmp(node->data_type, "int") == 0) {
        emit("PUSH %s", node->value);
    } else if(strcmp(node->type, "NUM") == 0 && strcmp(node->data_type, "float") == 0) {
        emit("FPUSH %s", node->value); // Assuming FPUSH for floats
    } else if (strcmp(node->type, "STRING_LIT") == 0) {
        int index = get_string_label_index(node->value);
        if (index != -1) {
            emit("PUSH STR_%d  ; Push address of string literal %s", index, node->value);
        }
    } else if(strcmp(node->type, "CHAR_LIT") == 0) {
        int ascii_val = (int)node->value[1];
        emit("PUSH %d ; Push ASCII for char %s", ascii_val, node->value);
    } else if (strcmp(node->type, "IDEN") == 0) {
        Symbol* s = lookup_symbol_codegen(node->value, scope, class_context);
        if (s) {
             if (strcmp(s->kind, "member_var") == 0) {
                 emit("LOAD 0 ; Load 'this' to access member '%s'", s->name);
                 int field_idx = get_field_index(s->class_name, s->name);
                 emit("GETFIELD %d", field_idx);
            } else if (strcmp(s->kind, "member_obj") == 0) {
                 emit("LOAD 0 ; Load 'this' to access member object '%s'", s->name);
                 fprintf(stderr, "Looking up field index for member object '%s' in class '%s'\n", s->name, s->class_name);
                 int field_idx = get_field_index(s->class_name, s->name);
                 emit("GETFIELD %d", field_idx);
            } else if (strcmp(s->kind, "parameter") == 0) {
                 emit("LOAD_ARG %d  ; Load parameter '%s'", s->address, s->name);
            } else {
                 emit("LOAD %d  ; Load local var %s", s->address, s->name);
            }
        } else {
            fprintf(stderr, "Codegen Error: Undefined symbol '%s' for expression.\n", node->value);
        }
    } else if (strcmp(node->type, "ARRAY_ACCESS") == 0) {
         generate_code_for_lval_address(node, scope, class_context); // Puts array_ref, index
         emit("ALOAD");
    } else if (strcmp(node->type, "MEMBER_VAR_ACCESS") == 0) {
        generate_code_for_lval_address(node, scope, class_context); // Pushes object ref
        int field_idx = get_field_index(node->children[0]->data_type, node->value);
        emit("GETFIELD %d ; Get field '%s'", field_idx, node->value);
    } else if (strcmp(node->type, "BIN_OP") == 0) {
        generate_code_for_expr(node->children[0], scope, class_context);
        generate_code_for_expr(node->children[1], scope, class_context);
        if (strcmp(node->value, "+") == 0 && strcmp(node->data_type, "int") == 0) emit("IADD");
        else if (strcmp(node->value, "+") == 0 && strcmp(node->data_type, "float") == 0) emit("FADD");
        else if (strcmp(node->value, "-") == 0 && strcmp(node->data_type, "int") == 0) emit("ISUB");
        else if (strcmp(node->value, "-") == 0 && strcmp(node->data_type, "float") == 0) emit("FSUB");
        else if (strcmp(node->value, "*") == 0 && strcmp(node->data_type, "int") == 0) emit("IMUL");
        else if (strcmp(node->value, "*") == 0 && strcmp(node->data_type, "float") == 0) emit("FMUL");
        else if (strcmp(node->value, "/") == 0 && strcmp(node->data_type, "int") == 0) emit("IDIV");
        else if (strcmp(node->value, "/") == 0 && strcmp(node->data_type, "float") == 0) emit("FDIV");
        else if (strcmp(node->value, "%") == 0 && strcmp(node->data_type, "int") == 0) emit("IMOD");
    } else if (strcmp(node->type, "UN_OP") == 0) {
        generate_code_for_expr(node->children[0], scope, class_context);
        if (strcmp(node->value, "-") == 0 && strcmp(node->data_type, "int") == 0) emit("INEG");
        else if (strcmp(node->value, "-") == 0 && strcmp(node->data_type, "float") == 0) emit("FNEG");
    } else if (strcmp(node->type, "MEMBER_FUNC_ACCESS") == 0) {
        Node* object_node = node->children[0];
        Node* func_call_node = node->children[1];
        Node* arg_list = func_call_node->children[0];
        
        // Push object reference ('this')
        generate_code_for_expr(object_node, scope, class_context);

        // Push arguments
        for (int i = 0; i < arg_list->num_children; i++) {
            generate_code_for_expr(arg_list->children[i], scope, class_context);
        }

        // Invoke
        fprintf(stderr, "Generating code for method call: %s on object of type %s\n", func_call_node->value, object_node->data_type);
        //char* mangled_name = get_mangled_name(func_call_node->value, arg_list);
        int method_idx = get_method_vtable_index(object_node->data_type, func_call_node->value);
        if (method_idx != -1) {
            emit("INVOKEVIRTUAL %d ; Call %s.%s", method_idx, object_node->data_type, func_call_node->value);
        } else {
             fprintf(stderr, "Codegen Error: Could not find method '%s' in class '%s'\n", func_call_node->value, object_node->data_type);
        }
        //free(mangled_name);
    } else if (strcmp(node->type, "FUNC_CALL") == 0) {
        Node* arg_list = node->children[0];
        for (int i = 0; i < arg_list->num_children; i++) {
            generate_code_for_expr(arg_list->children[i], scope, class_context);
        }
        emit("CALL %s", node->value);
    } else if (strcmp(node->type, "REL_OP") == 0 || strcmp(node->type, "BOOL_OP") == 0 || strcmp(node->type, "BOOL_CONST") == 0) {
        int true_label = new_label();
        int end_label = new_label();
        generate_code_for_boolean_expr(node, true_label, end_label, scope, class_context);
        fprintf(asm_file, "L%d:\n", true_label);
        emit("PUSH 1");
        emit("JMP L%d", end_label + 1);
        fprintf(asm_file, "L%d:\n", end_label);
        emit("PUSH 0");
        fprintf(asm_file, "L%d:\n", end_label + 1);
        label_count++;
    } else if (strcmp(node->type, "INDEX") == 0) {
        fprintf(stderr, "Generating code for array index expression: %s %s\n", node->value, node->children[0]->value);
    
        for(int i=0;i<node->num_children;++i) {
            generate_code_for_expr(node->children[i], scope, class_context);
            if(i == node->num_children - 1) break;
            emit("ALOAD ; Load array element");
        }
    } else if (strcmp(node->type, "POST_INC") == 0 || strcmp(node->type, "POST_DEC") == 0) {
        // Load current value
        Node* lval = node->children[0];
        Symbol* s = lookup_symbol_codegen(lval->value, scope, class_context);
        if(s) {
            emit("LOAD %d ; Load current value of %s for post %s", s->address, s->name, (strcmp(node->type, "POST_INC") == 0) ? "increment" : "decrement");
            emit("DUP"); // Duplicate for storing back
            if (strcmp(node->type, "POST_INC") == 0) {
                if(strcmp(s->type, "int") == 0) {
                    emit("PUSH 1");
                    emit("IADD");
                } else if(strcmp(s->type, "float") == 0) {
                    emit("FPUSH 1.0");
                    emit("FADD");
                }
            } else {
                if(strcmp(s->type, "int") == 0) {
                    emit("PUSH 1");
                    emit("ISUB");
                } else if(strcmp(s->type, "float") == 0) {
                    emit("FPUSH 1.0");
                    emit("FSUB");
                }
            }
            emit("STORE %d ; Post %s", s->address, (strcmp(node->type, "POST_INC") == 0) ? "increment" : "decrement");  
        } else {
            fprintf(stderr, "Codegen Error: Undefined symbol '%s' for post inc/dec.\n", lval->value);
        }
    } else if (strcmp(node->type, "PRE_INC") == 0 || strcmp(node->type, "PRE_DEC") == 0) {
        // Load current value
        Node* lval = node->children[0];
        Symbol* s = lookup_symbol_codegen(lval->value, scope, class_context);
        if(s) {
            emit("LOAD %d ; Load current value of %s for post %s", s->address, s->name, (strcmp(node->type, "POST_INC") == 0) ? "increment" : "decrement");
            if (strcmp(node->type, "POST_INC") == 0) {
                if(strcmp(s->type, "int") == 0) {
                    emit("PUSH 1");
                    emit("IADD");
                } else if(strcmp(s->type, "float") == 0) {
                    emit("FPUSH 1.0");
                    emit("FADD");
                }
            } else {
                if(strcmp(s->type, "int") == 0) {
                    emit("PUSH 1");
                    emit("ISUB");
                } else if(strcmp(s->type, "float") == 0) {
                    emit("FPUSH 1.0");
                    emit("FSUB");
                }
            }
            emit("DUP"); // Duplicate for storing back
            emit("STORE %d ; Post %s", s->address, (strcmp(node->type, "POST_INC") == 0) ? "increment" : "decrement"); 
        } else {
            fprintf(stderr, "Codegen Error: Undefined symbol '%s' for pre inc/dec.\n", lval->value);
        }
    } else {
        fprintf(stderr, "Codegen Warning: Unhandled expression type '%s'\n", node->type);
        for(int i=0; i<node->num_children; ++i) {
            generate_code_for_expr(node->children[i], scope, class_context);
        }
    }
    code_gen_depth--;
}

void generate_code_for_statement(Node* node, SymbolTable* scope, ClassInfo* class_context) {
    if (!node) return;
    debug_print("Gen STMT for: %s (%s)", node->type, node->value ? node->value : "");
    code_gen_depth++;

    if (strcmp(node->type, "ASSIGN") == 0) {
        Node* lval = node->children[0];
        Node* expr = node->children[2];
        
        if (strcmp(lval->type, "IDEN") == 0) {
            Symbol* s = lookup_symbol_codegen(lval->value, scope, class_context);
            if (s) {
                 if (strcmp(s->kind, "member_var") == 0) {
                    emit("LOAD_ARG 0 ; 'this' for assignment to member '%s'", s->name);
                    generate_code_for_expr(expr, scope, class_context);
                    int field_idx = get_field_index(s->class_name, s->name);
                    emit("PUTFIELD %d", field_idx);
                 } else {
                    generate_code_for_expr(expr, scope, class_context);
                    emit("STORE %d ; Store to local '%s'", s->address, s->name);
                 }
            } else {
                fprintf(stderr, "Codegen Error: Assignment to undeclared variable '%s'\n", lval->value);
            }
        } else if (strcmp(lval->type, "ARRAY_ACCESS") == 0) {
            generate_code_for_lval_address(lval, scope, class_context); // Puts array_ref, index
            generate_code_for_expr(expr, scope, class_context); // Puts value
            emit("ASTORE ; Store to array element");
        } else if (strcmp(lval->type, "MEMBER_VAR_ACCESS") == 0) {
            generate_code_for_lval_address(lval, scope, class_context); // Puts object_ref
            generate_code_for_expr(expr, scope, class_context); // Puts value
            int field_idx = get_field_index(lval->children[0]->data_type, lval->value);
            emit("PUTFIELD %d ; Set field '%s'", field_idx, lval->value);
        } else if (strcmp(lval->type, "MEMBER_ARRAY_ACCESS") == 0) {
            generate_code_for_lval_address(lval, scope, class_context); // Puts object_ref, index
            generate_code_for_expr(expr, scope, class_context); // Puts value
            int field_idx = get_field_index(lval->children[0]->data_type, lval->value);
            //emit("PUTFIELD %d ; Set array element in member '%s'", field_idx, lval->value);
            emit("ASTORE ; Store to member array element '%s'", lval->value);
        }
    } else if (strcmp(node->type, "FOR") == 0) {
        SymbolTable* for_scope = node->scope_table ? node->scope_table : scope;
        if (node->children[0]) { // Initialization
            generate_code_for_statement(node->children[0], for_scope, class_context);
        }
        int loop_start_label = new_label();
        int loop_body_label = new_label();
        int loop_increment_label = new_label();
        int loop_end_label = new_label();

        // Push labels for break and continue
        if (loop_stack_ptr < MAX_LOOP_DEPTH - 1) {
            loop_stack_ptr++;
            loop_break_labels[loop_stack_ptr] = loop_end_label;
            loop_continue_labels[loop_stack_ptr] = loop_increment_label;
        } else {
            fprintf(stderr, "Codegen Error: Loop stack overflow.\n");
        }

        emit("JMP L%d", loop_start_label);
        emit( "L%d:", loop_body_label);
        generate_assembly(node->children[3], for_scope); // Loop body
        emit("L%d:", loop_increment_label);
        if (node->children[2]) { // Increment
            generate_code_for_statement(node->children[2], for_scope, class_context);
            // Pop the result of the increment expression as it's not used 
            //  if (strcmp(node->children[2]->data_type, "void") != 0) {
            //      emit("POP");
            //  }
        }
        emit("L%d:", loop_start_label);
        if (node->children[1]) { // Condition
            generate_code_for_boolean_expr(node->children[1], loop_body_label, loop_end_label, for_scope, class_context);
        } else {
            emit("JMP L%d", loop_body_label); // No condition means infinite loop
        }

        emit("L%d:", loop_end_label);
        // Pop labels for break and continue
        if (loop_stack_ptr >= 0) {
            loop_stack_ptr--;
        } else {
            fprintf(stderr, "Codegen Error: Loop stack underflow.\n");
        }
    } else if(strcmp(node->type, "VAR_INIT") == 0) {
        Symbol* s = lookup_symbol_codegen(node->value, scope, class_context);
        if(s) {
            generate_code_for_expr(node->children[0], scope, class_context);
            emit("STORE %d ; Init %s", s->address, s->name);
        }
    } else if(strcmp(node->type, "ARRAY_DECL") == 0) {
        Symbol* s = lookup_symbol_codegen(node->value, scope, class_context);
        if(s) {
            // Flatten dimensions and use NEWARRAY
            Node* index_node = node->children[0];
            bool first_dim = true;

            // Generate code to calculate total size by multiplying dimensions.
            while(index_node) {
                generate_code_for_expr(index_node->children[0], scope, class_context);
                if (!first_dim) {
                    emit("IMUL ; Multiply dimensions for flattened array");
                }
                first_dim = false;

                if(index_node->num_children > 1) {
                    index_node = index_node->children[1];
                } else {
                    break;
                }
            }

            // Get the base type and emit the NEWARRAY instruction.
            char* base_type = get_base_array_type(s->type);
            emit("NEWARRAY %s", base_type);
            emit("STORE %d ; Store new flattened array to '%s'", s->address, s->name);
            free(base_type);
        }
        else {
            fprintf(stderr, "Codegen Error: Array declaration for undeclared variable '%s'\n", node->value);
        }
    } else if(strcmp(node->type, "OBJ_ARRAY_DECL") == 0) {
        Symbol* s = lookup_symbol_codegen(node->value, scope, class_context);
        if(s) {
            // Flatten dimensions and use NEWARRAY
            Node* index_node = node->children[0];
            bool first_dim = true;

            // Generate code to calculate total size by multiplying dimensions.
            while(index_node) {
                generate_code_for_expr(index_node->children[0], scope, class_context);
                if (!first_dim) {
                    emit("IMUL ; Multiply dimensions for flattened array");
                }
                first_dim = false;
                
                if(index_node->num_children > 1) {
                    index_node = index_node->children[1];
                } else {
                    break;
                }
            }
            
            // Get the base type (class name) and emit the NEWARRAY instruction.
            char* base_type = get_base_array_type(s->type);
            emit("NEWARRAY %s", base_type);
            emit("STORE %d ; Store new flattened object array to '%s'", s->address, s->name);
            free(base_type);
        } else {
            fprintf(stderr, "Codegen Error: Array declaration for undeclared variable '%s'\n", node->value);
        }
    } else if(strcmp(node->type, "OBJ_INIT") == 0) { // This is for `MyClass c = new MyClass();`
        Node* arg_list = node->children[0];
        Symbol* s = lookup_symbol_codegen(node->value, scope, class_context);
        if(!s) return;

        int class_idx = get_class_index(s->type);
        // check if class is abstract
        ClassInfo* class_info = find_class_info(s->type);
        if( class_info->is_abstract) {
            fprintf(stderr, "Codegen Error: Cannot instantiate abstract class '%s'\n", s->type);
            return;
        }
        emit("NEW %d ; Create new object of class %s", class_idx, s->type);
        emit("DUP");
        
        for (int i = 0; i < arg_list->num_children; i++) {
            generate_code_for_expr(arg_list->children[i], scope, class_context);
        }

        char* constructor_sig = get_mangled_name(s->type, arg_list);
        fprintf(stderr, "Debug: Constructor signature for '%s': %s\n", s->type, constructor_sig);
        int ctor_idx = get_method_vtable_index(s->type, constructor_sig);
        fprintf(stderr, "Debug: Constructor index for '%s': %d\n", s->type, ctor_idx);
        emit("INVOKESPECIAL %d ; Call constructor for %s", ctor_idx, s->type);
        free(constructor_sig);

        emit("STORE %d ; Store new object to '%s'", s->address, s->name);

    } else if (strcmp(node->type, "IF") == 0) {
        int true_label = new_label();
        int end_if_label = new_label();
        generate_code_for_boolean_expr(node->children[0], true_label, end_if_label, scope, class_context);
        emit("L%d:", true_label);
        generate_assembly(node->children[1], node->scope_table ? node->scope_table : scope);
        emit("L%d:", end_if_label);
    } else if (strcmp(node->type, "IF_ELSE") == 0) {
        int true_label = new_label();
        int false_label = new_label();
        int end_label = new_label();
        generate_code_for_boolean_expr(node->children[0], true_label, false_label, scope, class_context);
        emit("L%d:", true_label);
        generate_assembly(node->children[1], node->scope_table ? node->scope_table : scope); 
        emit("JMP L%d", end_label);
        emit("L%d:", false_label);
        generate_assembly(node->children[2], node->scope_table ? node->scope_table : scope);
        emit("L%d:", end_label);
    } else if (strcmp(node->type, "WHILE") == 0) {
        int loop_start_label = new_label();
        int loop_body_label = new_label();
        int loop_end_label = new_label();

        if (loop_stack_ptr < MAX_LOOP_DEPTH - 1) {
            loop_stack_ptr++;
            loop_break_labels[loop_stack_ptr] = loop_end_label;
            loop_continue_labels[loop_stack_ptr] = loop_start_label;
        } else {
            fprintf(stderr, "Codegen Error: Loop stack overflow.\n");
        }

        emit("L%d:", loop_start_label);
        generate_code_for_boolean_expr(node->children[0], loop_body_label, loop_end_label, scope, class_context);
        emit("L%d:", loop_body_label);
        generate_assembly(node->children[1], node->scope_table ? node->scope_table : scope);
        emit("JMP L%d", loop_start_label);
        emit("L%d:", loop_end_label);

        if (loop_stack_ptr >= 0) {
            loop_stack_ptr--;
        } else {
            fprintf(stderr, "Codegen Error: Loop stack underflow.\n");
        }
    } else if (strcmp(node->type, "DO_WHILE") == 0) {
        int loop_body_label = new_label();
        int loop_condition_label = new_label();
        int loop_end_label = new_label();

        if (loop_stack_ptr < MAX_LOOP_DEPTH - 1) {
            loop_stack_ptr++;
            loop_break_labels[loop_stack_ptr] = loop_end_label;
            loop_continue_labels[loop_stack_ptr] = loop_condition_label;
        } else {
            fprintf(stderr, "Codegen Error: Loop stack overflow.\n");
        }

        emit("L%d:", loop_body_label);
        generate_assembly(node->children[0], node->scope_table ? node->scope_table : scope);
        emit("L%d:", loop_condition_label);
        generate_code_for_boolean_expr(node->children[1], loop_body_label, loop_end_label, scope, class_context);
        emit("L%d:", loop_end_label);

        if (loop_stack_ptr >= 0) {
            loop_stack_ptr--;
        } else {
            fprintf(stderr, "Codegen Error: Loop stack underflow.\n");
        }
    } else if (strcmp(node->type, "BREAK") == 0) {
        if (loop_stack_ptr >= 0) {
            emit("JMP L%d ; BREAK", loop_break_labels[loop_stack_ptr]);
        } else {
            fprintf(stderr, "Codegen Error: 'break' used outside of a loop.\n");
        }
    } else if (strcmp(node->type, "CONTINUE") == 0) {
        if (loop_stack_ptr >= 0) {
            emit("JMP L%d ; CONTINUE", loop_continue_labels[loop_stack_ptr]);
        } else {
            fprintf(stderr, "Codegen Error: 'continue' used outside of a loop.\n");
        }
    } else if (strcmp(node->type, "RETURN") == 0) {
        if (node->num_children > 0) {
            generate_code_for_expr(node->children[0], scope, class_context);
        }
        //emit("RET");
    } else if (strcmp(node->type, "EXPR_STMT") == 0) {
        generate_code_for_expr(node->children[0], scope, class_context);
        // Discard result if not a function call
        if(strcmp(node->children[0]->data_type, "float") == 0) {
            emit("FPOP"); 
        } else if(strcmp(node->children[0]->data_type, "int") == 0 || strcmp(node->children[0]->data_type, "char") == 0) {
            emit("POP"); 
        } else {
            // For void functions or other types, no pop needed
        }
    } else if (strcmp(node->type, "DECL_LIST") == 0) {
        for (int i = 0; i < node->num_children; i++) {
            generate_assembly(node->children[i], node->scope_table ? node->scope_table : scope);
        }
    } else if (strcmp(node->type, "DECL_STMT") == 0) {
        generate_assembly(node->children[1], node->scope_table ? node->scope_table : scope);
    } else if (strcmp(node->type, "STATEMENTS") == 0) {
        for (int i = 0; i < node->num_children; i++) {
            generate_assembly(node->children[i], node->scope_table ? node->scope_table : scope);
        }
    } else {
        for(int i=0; i<node->num_children; ++i) {
            generate_assembly(node->children[i], node->scope_table ? node->scope_table : scope);
        }
    }
    code_gen_depth--;
}


void generate_assembly(Node* node, SymbolTable* scope) {
    if (!node) return;
    debug_print("Gen ASM for: %s (%s)", node->type, node->value ? node->value : "");
    code_gen_depth++;

    SymbolTable* next_scope = node->scope_table ? node->scope_table : scope;
    ClassInfo* class_context = find_class_info(current_class_name);

    if (strcmp(node->type, "PROGRAM") == 0 || strcmp(node->type, "STATEMENTS") == 0 || strcmp(node->type, "DECL_LIST") == 0 || strcmp(node->type, "CLASS_BODY") == 0) {
        for (int i = 0; i < node->num_children; i++) {
            generate_assembly(node->children[i], next_scope);
        }
    } else if (strcmp(node->type, "CLASS_DECL") == 0) {
        current_class_name = node->value;
        generate_assembly(node->children[1], next_scope); // Process CLASS_BODY
        current_class_name = NULL;
    } else if (strcmp(node->type, "FUNC_DEF") == 0) {
        int locals = calculate_total_locals(node->scope_table);
        int stack = calculate_max_stack_depth(node->children[2]);
        if (stack < 4) stack = 4; // Ensure a minimum stack size

        fprintf(asm_file, "\n.method %s\n", node->value);
        emit(".limit stack %d", stack);
        emit(".limit locals %d", locals);
        generate_assembly(node->children[2], node->scope_table);
        emit("RET");
        fprintf(asm_file, ".endmethod\n");
    } else if (strcmp(node->type, "CONSTRUCTOR") == 0) {
         char mangled_name[512];
         sprintf(mangled_name, "%s@constructor", node->value);
         
         int locals = calculate_total_locals(node->scope_table);
         int stack = calculate_max_stack_depth(node->children[1]);
         if (stack < 4) stack = 4;

         fprintf(asm_file, "\n.method %s\n", mangled_name);
         emit(".limit stack %d", stack);
         emit(".limit locals %d", locals);
         generate_assembly(node->children[1], node->scope_table);
         emit("RET");
         fprintf(asm_file, ".endmethod\n");
    } else {
        generate_code_for_statement(node, next_scope, class_context);
    }
    code_gen_depth--;
}

// --- Main & Error Functions ---

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    }
    
    yylineno = 1;
    init_symbol_table();
    yyparse();

    // After parsing, write metadata before code
    if (root) {
        FILE *output_file = fopen("parser_output.txt", "w");
        if (output_file) {
            write_tree_to_file(root, output_file, 0);
            fclose(output_file);
        }
        
        asm_file = fopen("code.asm", "w");
        if(asm_file) {
            printf("\nGenerating assembly code in code.asm...\n");

            // --- Emit Metadata Section ---
            emit(".class_metadata");
            emit("class_count %d", class_pool_count);
            for (int i = 0; i < class_pool_count; i++) {
                ClassInfo* cls = class_metadata_pool[i];
                int super_idx = (cls->parent_count > 0) ? get_class_index(cls->parent_names[0]) : -1;
                emit("class_begin %s %d", cls->name, super_idx);
                
                emit("field_count %d", cls->field_count);
                for(int j=0; j<cls->field_count; ++j) {
                    // Type 0 = int, 1 = float, 2=object_ref/array_ref
                    emit("field %s %s %d", cls->fields[j].name, cls->fields[j].type, 0); 
                }

                emit("method_count %d", cls->method_count);
                 for(int j=0; j<cls->method_count; ++j) {
                    emit("method %s %s.%s", cls->methods[j].name, cls->name, cls->methods[j].name);
                }
                emit("class_end");
            }
            emit(".end_metadata");
            emit("\n.code");

            // --- Emit Code Section ---
            generate_assembly(root, all_tables[0]);
            if (string_pool_count > 0 || array_descriptor_count > 0) {
                fprintf(asm_file, "\n.data\n");
                for (int i = 0; i < string_pool_count; i++) {
                    fprintf(asm_file, "STR_%d: .word \"%s\"\n", i, string_pool[i]);
                    free(string_pool[i]);
                }
                for (int i = 0; i < array_descriptor_count; i++) {
                    fprintf(asm_file, "A%d: .word \"%s\"\n", i, array_descriptor_pool[i]);
                    free(array_descriptor_pool[i]);
                }
            }
            
            fclose(asm_file);
        }
    }

    FILE* sym_file = fopen("symbol_table.txt", "w");
    if (sym_file) {
        printf("\nWriting symbol table to symbol_table.txt...\n");
        for (int i = 0; i < table_count; i++) {
            print_table_to_file(all_tables[i], sym_file);
        }
        fclose(sym_file);
    }

    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}

// --- Tree Printing Functions ---

void print_tree(Node* node, int level) {
    if (node == NULL) return;
    for (int i = 0; i < level; i++) printf("  ");
    printf("%s", node->type);
    if (node->value != NULL) printf(" (%s)", node->value);
    printf(" [type: %s]\n", node->data_type);
    for (int i = 0; i < node->num_children; i++) {
        print_tree(node->children[i], level + 1);
    }
}

void write_tree_to_file(Node* node, FILE* file, int level) {
    if (node == NULL || file == NULL) return;
    for (int i = 0; i < level; i++) fprintf(file, "  ");
    fprintf(file, "%s", node->type);
    if (node->value != NULL) fprintf(file, " (%s)", node->value);
    fprintf(file, " [type: %s]\n", node->data_type);
    for (int i = 0; i < node->num_children; i++) {
        write_tree_to_file(node->children[i], file, level + 1);
    }
}

