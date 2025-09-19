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

typedef struct Symbol {
    char* name;
    char* type;
    char* kind;           // e.g., "variable", "function", "class", "member_var"
    char* access_spec;    // "public", "private", "protected", or "default"
    char* class_name;     // Name of the class if it's a member
    int scope;
    int line_declared;
    int address;          // For code generation (e.g., local variable index)
} Symbol;

typedef struct SymbolTable {
    Symbol* symbols[TABLE_SIZE];
    int count;
    int scope;
    struct SymbolTable* parent;
} SymbolTable;

SymbolTable* current_table;
SymbolTable* all_tables[TABLE_SIZE * 10];
int table_count = 0;
int local_address_counter = 0; // For assigning local variable addresses

// --- Data Structures for Class Metadata ---

typedef struct FieldInfo {
    char* name;
    char* type;
    char* access_spec;
} FieldInfo;

typedef struct MethodInfo {
    char* name;
    char* return_type;
    char* access_spec;
} MethodInfo;

typedef struct ClassInfo {
    char* name;
    FieldInfo fields[TABLE_SIZE];
    int field_count;
    MethodInfo methods[TABLE_SIZE];
    int method_count;
} ClassInfo;

ClassInfo* class_metadata_pool[TABLE_SIZE];
int class_pool_count = 0;
ClassInfo* current_class_info = NULL; // Pointer to the class currently being parsed


// --- Helper Functions for Type Checking & Symbol Management ---

char* current_function_return_type;
int has_return_statement;
char* current_class_name = NULL;
char* current_access_spec = "private"; // Default for classes

// Forward declaration
void insert_symbol(char* name, char* type, char* kind);
Symbol* lookup_symbol_codegen(char* name, SymbolTable* scope);


// Helper function to recursively build a nested type string for multi-dimensional arrays
char* build_array_type(const char* base_type, Node* index_node) {
    if (index_node == NULL) {
        return strdup(base_type);
    }
    char* inner_type;
    // Recursively call for the rest of the dimensions
    if (index_node->num_children == 2) { // case: '[' EXPR ']' INDEX
        inner_type = build_array_type(base_type, index_node->children[1]);
    } else { // base case: '[' EXPR ']'
        inner_type = strdup(base_type);
    }
    char* final_type = malloc(strlen(inner_type) + 10);
    sprintf(final_type, "array(%s)", inner_type);
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
    // Added for char and string
    if (strcmp(lval_type, "char") == 0 && strcmp(rval_type, "char") == 0) return 1;
    if (strcmp(lval_type, "string") == 0 && strcmp(rval_type, "string") == 0) return 1;
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
    fprintf(file, "%-20s | %-15s | %-12s | %-12s | %-15s | %s\n", "Name", "Type", "Kind", "Access", "Class", "Line Declared");
    fprintf(file, "------------------------------------------------------------------------------------------------------\n");
    for (int i = 0; i < table->count; i++) {
        Symbol* s = table->symbols[i];
        fprintf(file, "%-20s | %-15s | %-12s | %-12s | %-15s | %d\n", s->name, s->type, s->kind, s->access_spec, s->class_name ? s->class_name : "N/A", s->line_declared);
    }
}


void init_symbol_table() {
    current_table = (SymbolTable*)malloc(sizeof(SymbolTable));
    current_table->count = 0;
    current_table->scope = 0;
    current_table->parent = NULL;
    all_tables[table_count++] = current_table;
}

void enter_scope() {
    SymbolTable* new_table = (SymbolTable*)malloc(sizeof(SymbolTable));
    new_table->count = 0;
    new_table->scope = (current_table->scope) + 1;
    new_table->parent = current_table;
    current_table = new_table;
    all_tables[table_count++] = current_table;
    // Reset local address counter only when entering a function-level scope
    if (new_table->parent->scope == 0 || current_function_return_type != NULL) { 
        local_address_counter = 0;
    }
}

void exit_scope() {
    if (current_table->parent != NULL) {
        current_table = current_table->parent;
    }
}

void insert_symbol(char* name, char* type, char* kind) {
    for (int i = 0; i < current_table->count; i++) {
        if (strcmp(current_table->symbols[i]->name, name) == 0) {
            fprintf(stderr, "Error at line %d: Redeclaration of '%s'\n", yylineno, name);
            return;
        }
    }

    if (current_table->count < TABLE_SIZE) {
        Symbol* symbol = (Symbol*)malloc(sizeof(Symbol));
        symbol->name = strdup(name);
        symbol->type = strdup(type);
        symbol->kind = strdup(kind);
        symbol->scope = current_table->scope;
        symbol->line_declared = yylineno;
        symbol->access_spec = strdup(current_access_spec);
        symbol->class_name = current_class_name ? strdup(current_class_name) : NULL;
        symbol->address = (strcmp(kind, "variable") == 0 || strcmp(kind, "member_var") == 0) ? local_address_counter++ : -1;
        current_table->symbols[current_table->count++] = symbol;

        // If inside a class, add to metadata
        if (current_class_info) {
            if (strcmp(kind, "member_var") == 0) {
                FieldInfo* field = &current_class_info->fields[current_class_info->field_count++];
                field->name = strdup(name);
                field->type = strdup(type);
                field->access_spec = strdup(current_access_spec);
            } else if (strcmp(kind, "member_func") == 0) {
                MethodInfo* method = &current_class_info->methods[current_class_info->method_count++];
                method->name = strdup(name);
                method->return_type = strdup(type);
                method->access_spec = strdup(current_access_spec);
            }
        }
    } else {
        fprintf(stderr, "Error: Symbol table overflow.\n");
    }
}

// Original lookup for use during parsing
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
%token <str_val> CLASS PUBLIC PRIVATE PROTECTED ABSTRACT
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

%%

S: STMNTS M  { $$ = create_node("PROGRAM", NULL); add_child($$, $1); root = $$; }
 |            { $$ = create_node("PROGRAM", "empty"); root = $$; }
 | error      { yyerrok; $$ = create_node("PROGRAM", "error"); root = $$; }
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
              insert_symbol($2, $1->value, current_class_name ? "member_func" : "function");
              current_function_return_type = $1->value;
              has_return_statement = 0;
              enter_scope();
          } PARAMLIST ')' '{' STMNTS '}' {
              SymbolTable* func_scope = current_table;
              if (strcmp(current_function_return_type, "void") != 0 && !has_return_statement) {
                  fprintf(stderr, "Error at line %d: Missing return statement in non-void function '%s'.\n", yylineno, $2);
              }
              exit_scope();
              current_function_return_type = NULL;
              
              $$ = create_node("FUNC_DEF", $2);
              add_child($$, $1);
              add_child($$, $5);
              add_child($$, $8);
              $$->scope_table = func_scope;
          }
        ;

PARAMLIST: PARAM ',' PARAMLIST { $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); add_child($$, $3); }
         | PARAM               { $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); }
         |                     { $$ = create_node("PARAM_LIST", "empty"); }
         ;

PARAM: TYPE IDEN {
        insert_symbol($2, $1->value, "variable");
        $$ = create_node("PARAM", $2);
        add_child($$, $1);
     }
     | TYPE IDEN INDEX {
        char* array_type = build_array_type($1->value, $3);
        insert_symbol($2, array_type, "variable");
        $$ = create_node("PARAM_ARRAY", $2);
        add_child($$, $1);
        add_child($$, $3);
        free(array_type);
     }
     ;

DECLSTATEMENT: TYPE DECLLIST ';' {
                 $$ = create_node("DECL_STMT", NULL);
                 add_child($$, $1);
                 add_child($$, $2);
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
        insert_symbol($1, current_decl_type, current_class_name ? "member_var" : "variable");
        $$ = create_node("VAR_DECL", $1);
      }
    | IDEN '=' EXPR {
        insert_symbol($1, current_decl_type, current_class_name ? "member_var" : "variable");
        if (!are_types_compatible(current_decl_type, $3->data_type)) {
            fprintf(stderr, "Error line %d: Incompatible types in initialization. Cannot assign '%s' to '%s'\n", yylineno, $3->data_type, current_decl_type);
        }
        $$ = create_node("VAR_INIT", $1);
        add_child($$, $3);
      }
    | IDEN INDEX {
        char* array_type = build_array_type(current_decl_type, $2);
        insert_symbol($1, array_type, current_class_name ? "member_var" : "variable");
        $$ = create_node("ARRAY_DECL", $1);
        add_child($$, $2);
        free(array_type);
      }
    | IDEN INDEX '=' '{' INITLIST '}' {
        char* array_type = build_array_type(current_decl_type, $2);
        insert_symbol($1, array_type, current_class_name ? "member_var" : "variable");
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

INDEX: '[' EXPR ']' { $$ = create_node("INDEX", NULL); add_child($$, $2); }
     | '[' EXPR ']' INDEX { $$ = create_node("INDEX", NULL); add_child($$, $2); add_child($$, $4); }
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
        if (s == NULL) {
            fprintf(stderr, "Error line %d: Variable '%s' not defined\n", yylineno, $1);
            $$ = create_node("IDEN", $1);
        } else {
            $$ = create_node("IDEN", $1);
            $$->data_type = strdup(s->type);
        }
      }
    | IDEN INDEX {
        Symbol* s = lookup_symbol($1);
        char* current_type;
        if (s == NULL) {
            fprintf(stderr, "Error line %d: Array '%s' not defined\n", yylineno, $1);
            current_type = strdup("undefined");
        } else {
            current_type = strdup(s->type);
        }

        Node* index_node = $2;
        while (index_node != NULL) {
            Node* expr_node = index_node->children[0];
            if (strcmp(expr_node->data_type, "int") != 0) {
                fprintf(stderr, "Error line %d: Array index for '%s' is not an integer (got '%s')\n", yylineno, $1, expr_node->data_type);
            }
            if (strncmp(current_type, "array(", 6) == 0) {
                char* temp = strdup(current_type + 6);
                temp[strlen(temp) - 1] = '\0';
                free(current_type);
                current_type = temp;
            } else {
                fprintf(stderr, "Error line %d: Too many dimensions for array '%s'. '%s' is not an array type.\n", yylineno, $1, current_type);
                free(current_type);
                current_type = strdup("undefined");
                break;
            }
            if (index_node->num_children == 2) {
                index_node = index_node->children[1];
            } else {
                index_node = NULL;
            }
        }
        
        $$ = create_node("ARRAY_ACCESS", $1);
        add_child($$, $2);
        $$->data_type = current_type;
      }
    ;

ASNEXPR: LVAL ASSGN EXPR {
           if (!are_types_compatible($1->data_type, $3->data_type)) {
               fprintf(stderr, "Error line %d: Type mismatch in assignment. Cannot assign '%s' to '%s'\n", yylineno, $3->data_type, $1->data_type);
           }
           $$ = create_node("ASSIGN", NULL);
           add_child($$, $1);
           add_child($$, $2);
           add_child($$, $3);
         }
       | EXPR { $$ = $1; }
       ;

BOOLEXPR: BOOLEXPR OR M BOOLEXPR   { $$ = create_node("BOOL_OP", "||"); add_child($$, $1); add_child($$, $4); $$->data_type="bool"; }
        | BOOLEXPR AND M BOOLEXPR  { $$ = create_node("BOOL_OP", "&&"); add_child($$, $1); add_child($$, $4); $$->data_type="bool"; }
        | '!' BOOLEXPR             { $$ = create_node("BOOL_OP", "!"); add_child($$, $2); $$->data_type="bool"; }
        | '(' BOOLEXPR ')'         { $$ = $2; }
        | EXPR LT EXPR             { $$ = create_node("REL_OP", "<"); add_child($$, $1); add_child($$, $3); $$->data_type="bool"; }
        | EXPR GT EXPR             { $$ = create_node("REL_OP", ">"); add_child($$, $1); add_child($$, $3); $$->data_type="bool"; }
        | EXPR EQ EXPR             { $$ = create_node("REL_OP", "=="); add_child($$, $1); add_child($$, $3); $$->data_type="bool"; }
        | EXPR NE EXPR             { $$ = create_node("REL_OP", "!="); add_child($$, $1); add_child($$, $3); $$->data_type="bool"; }
        | EXPR LE EXPR             { $$ = create_node("REL_OP", "<="); add_child($$, $1); add_child($$, $3); $$->data_type="bool"; }
        | EXPR GE EXPR             { $$ = create_node("REL_OP", ">="); add_child($$, $1); add_child($$, $3); $$->data_type="bool"; }
        | TR                       { $$ = create_node("BOOL_CONST", "true"); $$->data_type="bool"; }
        | FL                       { $$ = create_node("BOOL_CONST", "false"); $$->data_type="bool"; }
        ;

EXPR: EXPR '+' EXPR { $$ = create_node("BIN_OP", "+"); add_child($$, $1); add_child($$, $3); $$->data_type = get_promoted_type($1->data_type, $3->data_type); }
    | EXPR '-' EXPR { $$ = create_node("BIN_OP", "-"); add_child($$, $1); add_child($$, $3); $$->data_type = get_promoted_type($1->data_type, $3->data_type); }
    | EXPR '*' EXPR { $$ = create_node("BIN_OP", "*"); add_child($$, $1); add_child($$, $3); $$->data_type = get_promoted_type($1->data_type, $3->data_type); }
    | EXPR '/' EXPR { $$ = create_node("BIN_OP", "/"); add_child($$, $1); add_child($$, $3); $$->data_type = get_promoted_type($1->data_type, $3->data_type); }
    | EXPR '%' EXPR { $$ = create_node("BIN_OP", "%"); add_child($$, $1); add_child($$, $3); $$->data_type = "int"; }
    | BOOLEXPR '?' EXPR ':' EXPR { $$ = create_node("TERNARY_OP", NULL); add_child($$, $1); add_child($$, $3); add_child($$, $5); $$->data_type = $3->data_type; }
    | FUNC_CALL     { $$ = $1; }
    | TERM          { $$ = $1; }
    | '-' EXPR %prec UMINUS { $$ = create_node("UN_OP", "-"); add_child($$, $2); $$->data_type = strdup($2->data_type); }
    ;

FUNC_CALL: IDEN '(' ARGLIST ')' {
            Symbol* s = lookup_symbol($1);
            $$ = create_node("FUNC_CALL", $1);
            add_child($$, $3);
            if (s == NULL) {
                fprintf(stderr, "Error line %d: Function '%s' is not defined.\n", yylineno, $1);
                $$->data_type = "undefined";
            } else {
                $$->data_type = strdup(s->type);
            }
         }
         ;

ARGLIST: EXPR ',' ARGLIST { $$ = $3; add_child($$, $1); }
       | EXPR            { $$ = create_node("ARG_LIST", NULL); add_child($$, $1); }
       |                 { $$ = create_node("ARG_LIST", "empty"); }
       ;

TERM: LVAL { $$ = $1; }
    | NUM  { $$ = create_node("NUM", $1); $$->data_type = (strchr($1, '.') ? "float" : "int"); }
    | STR  { $$ = create_node("STRING_LIT", $1); $$->data_type = "string"; }
    | CHR  { $$ = create_node("CHAR_LIT", $1); $$->data_type = "char"; }
    // | TR   { $$ = create_node("BOOL_CONST", "true"); $$->data_type="bool"; }
    // | FL   { $$ = create_node("BOOL_CONST", "false"); $$->data_type="bool"; }
    | '(' EXPR ')' { $$ = $2; }
    | LVAL INC { $$ = create_node("POST_INC", "++"); add_child($$, $1); $$->data_type = $1->data_type; }
    | LVAL DEC { $$ = create_node("POST_DEC", "--"); add_child($$, $1); $$->data_type = $1->data_type; }
    | INC LVAL { $$ = create_node("PRE_INC", "++"); add_child($$, $2); $$->data_type = $2->data_type; }
    | DEC LVAL { $$ = create_node("PRE_DEC", "--"); add_child($$, $2); $$->data_type = $2->data_type; }
    ;

/* --- OOP Grammar --- */
CLASSDECL: CLASS IDEN OPT_INHERIT '{' CLASSBODY '}' ';' {
            $$ = create_node("CLASS_DECL", $2);
            add_child($$, $3); // OPT_INHERIT
            add_child($$, $5); // CLASSBODY
            $$->scope_table = current_table;
            exit_scope();
            current_class_name = NULL;
            current_class_info = NULL;
           };

OPT_INHERIT: ':' INHERITLIST {
                $$ = $2;
             }
           | /* empty */ {
                // Actions for when a class is declared (before body)
                // This is a bit tricky since IDEN is consumed before OPT_INHERIT
                // We'll handle this in CLASSDECL before OPT_INHERIT is parsed.
                // For now, just create an empty node.
                $$ = create_node("NO_INHERITANCE", NULL);
             }
           ;

INHERITLIST: ACCESS IDEN {
                $$ = create_node("INHERIT_LIST", NULL);
                Node* inherit_item = create_node("INHERIT_ITEM", $2);
                add_child(inherit_item, $1);
                add_child($$, inherit_item);
             }
           | ACCESS IDEN ',' INHERITLIST {
                $$ = $4;
                Node* inherit_item = create_node("INHERIT_ITEM", $2);
                add_child(inherit_item, $1);
                add_child($$, inherit_item);
             }
           ;


CLASSBODY: CLASSBODY CLASSMEMBER { $$ = $1; add_child($$, $2); }
         | CLASSMEMBER           { $$ = create_node("CLASS_BODY", NULL); add_child($$, $1); }
         ;

CLASSMEMBER: ACCESS MODIFIER_DECL { 
                current_access_spec = $1->value; 
                $$ = $2; 
             }
           | ACCESS FUNCDECL { 
                current_access_spec = $1->value; 
                $$ = $2; 
             }
           | ACCESS ABSTRACTFUNC {
                current_access_spec = $1->value;
                $$ = $2;
             }
           | ACCESS CONSTRUCTOR { 
                current_access_spec = $1->value; 
                $$ = $2; 
             }
           | ACCESS DESTRUCTOR { 
                current_access_spec = $1->value; 
                $$ = $2; 
             }
           ;

ACCESS: PUBLIC    { $$ = create_node("ACCESS", "public"); }
      | PRIVATE   { $$ = create_node("ACCESS", "private"); }
      | PROTECTED { $$ = create_node("ACCESS", "protected"); }
      | /* empty */ { $$ = create_node("ACCESS", "private"); /* Default access */ }
      ;

MODIFIER_DECL: TYPE DECLLIST ';' {
                $$ = create_node("MEMBER_DECL", NULL);
                add_child($$, $1);
                add_child($$, $2);
              }
              ;

CONSTRUCTOR: IDEN '(' PARAMLIST ')' '{' STMNTS '}' ';' {
                if (strcmp($1, current_class_name) != 0) {
                    fprintf(stderr, "Error line %d: Constructor name '%s' must match class name '%s'.\n", yylineno, $1, current_class_name);
                }
                $$ = create_node("CONSTRUCTOR", $1);
                add_child($$, $3);
                add_child($$, $6);
             }
             ;

DESTRUCTOR: '~' IDEN '(' ')' '{' STMNTS '}' ';' {
                if (strcmp($2, current_class_name) != 0) {
                    fprintf(stderr, "Error line %d: Destructor name '~%s' must match class name '%s'.\n", yylineno, $2, current_class_name);
                }
                $$ = create_node("DESTRUCTOR", $2);
                add_child($$, $6);
            }
            ;

ABSTRACTCLASS: ABSTRACT CLASS IDEN OPT_INHERIT '{' ABSTRACTBODY '}' ';' {
                $$ = create_node("ABSTRACT_CLASS", $3);
                add_child($$, $4);
                add_child($$, $6);
                exit_scope();
                current_class_name = NULL;
             }
             ;

ABSTRACTBODY: ABSTRACTBODY ABSTRACTMEMBER { $$ = $1; add_child($$, $2); }
            | ABSTRACTMEMBER             { $$ = create_node("ABSTRACT_BODY", NULL); add_child($$, $1); }
            ;

ABSTRACTMEMBER: ACCESS ABSTRACTFUNC { current_access_spec = $1->value; $$ = $2; }
              ;

ABSTRACTFUNC: TYPE IDEN '(' PARAMLIST ')' ';' {
                insert_symbol($2, $1->value, "abstract_method");
                $$ = create_node("ABSTRACT_FUNC", $2);
                add_child($$, $1);
                add_child($$, $4);
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

void generate_code_for_expr(Node* node, SymbolTable* scope); // Forward declare

// --- Codegen Helper Functions ---
int calculate_total_locals(SymbolTable* func_scope) {
    int max_addr = -1;
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
                if ((strcmp(s->kind, "variable") == 0) && s->address > max_addr) {
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
    if (strcmp(node->type, "FUNC_CALL") == 0) {
        int max_arg_depth = 0;
        Node* arg_list = node->children[0];
        for (int i = 0; i < arg_list->num_children; i++) {
             int arg_depth = calculate_max_stack_depth(arg_list->children[i]) + i;
             if(arg_depth > max_arg_depth) max_arg_depth = arg_depth;
        }
        return max_arg_depth;
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

int new_label() {
    return label_count++;
}

// Function to add a string literal to the pool and get its label index
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


// New lookup function for code generation that uses the provided scope
Symbol* lookup_symbol_codegen(char* name, SymbolTable* scope) {
    SymbolTable* table = scope;
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

void generate_code_for_boolean_expr(Node* node, int true_label, int false_label, SymbolTable* scope) {
    if (!node) return;
    debug_print("Gen BOOL EXPR for: %s (%s)", node->type, node->value ? node->value : "");
    code_gen_depth++;

    if (strcmp(node->type, "REL_OP") == 0) {
        generate_code_for_expr(node->children[0], scope);
        generate_code_for_expr(node->children[1], scope);
        if (strcmp(node->value, "<") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_LT");
        else if (strcmp(node->value, "<") == 0) emit("ICMP_LT");
        else if (strcmp(node->value, "<=") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_LE");
        else if (strcmp(node->value, "<=") == 0) emit("ICMP_LE");
        else if (strcmp(node->value, "!=") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_NEQ");
        else if (strcmp(node->value, "!=") == 0) emit("ICMP_NEQ");
        else if (strcmp(node->value, ">=") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_GE");
        else if (strcmp(node->value, ">=") == 0) emit("ICMP_GE");
        else if (strcmp(node->value, "==") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_EQ");
        else if (strcmp(node->value, "==") == 0) emit("ICMP_EQ");
        else if (strcmp(node->value, ">") == 0 && strcmp(node->children[0]->data_type, "float") == 0 && strcmp(node->children[1]->data_type, "float") == 0) emit("FCMP_GT");
        else if (strcmp(node->value, ">") == 0) emit("ICMP_GT");
        else if (strcmp(node->value, "==") == 0) emit("ICMP_EQ");
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
            generate_code_for_boolean_expr(node->children[0], next_cond_label, false_label, scope);
            emit("L%d:", next_cond_label);
            generate_code_for_boolean_expr(node->children[1], true_label, false_label, scope);
        } else if (strcmp(node->value, "||") == 0) {
            int next_cond_label = new_label();
            generate_code_for_boolean_expr(node->children[0], true_label, next_cond_label, scope);
            emit("L%d:", next_cond_label);
            generate_code_for_boolean_expr(node->children[1], true_label, false_label, scope);
        }
    } else { 
        generate_code_for_expr(node, scope);
        emit("JNZ L%d", true_label);
        emit("JMP L%d", false_label);
    }
    code_gen_depth--;
}