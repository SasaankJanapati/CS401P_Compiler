%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
extern int yylineno; // To report line numbers in errors
int yydebug = 0;

// Forward declarations
void yyerror(const char* s);
int yylex();

// --- Data Structures for Parse Tree ---

typedef struct Node {
    char* type;
    char* value;
    char* data_type; // For type checking
    int num_children;
    struct Node** children;
} Node;

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
    int scope;
    int line_declared;
} Symbol;

typedef struct SymbolTable {
    Symbol* symbols[TABLE_SIZE];
    int count;
    int scope;
    struct SymbolTable* parent;
} SymbolTable;

SymbolTable* current_table;
SymbolTable* all_tables[TABLE_SIZE * 10]; // To store all scopes for final printing
int table_count = 0;

// --- Helper Functions for Strict Type Checking ---

char* current_function_return_type; // Holds the expected return type of the current function
int has_return_statement; // Flag to track if a return was found in the current function

// Forward declaration for helper
void insert_symbol(char* name, char* type);

// Traverses a PARAM_LIST node and adds its parameters to the current scope.
void add_params_to_scope(Node* param_list_node) {
    if (param_list_node == NULL || strcmp(param_list_node->type, "PARAM_LIST") != 0) {
        return;
    }

    for (int i = 0; i < param_list_node->num_children; i++) {
        Node* child = param_list_node->children[i];
        if (strcmp(child->type, "PARAM") == 0 || strcmp(child->type, "PARAM_ARRAY") == 0) {
            char* param_type = child->children[0]->value;
            char* param_name = child->value;
            insert_symbol(param_name, param_type);
        } else if (strcmp(child->type, "PARAM_LIST") == 0) {
            add_params_to_scope(child);
        }
    }
}


// Returns 1 if types are compatible for assignment (rval to lval).
// Allows int -> float (widening), but not float -> int (narrowing).
int are_types_compatible(char* lval_type, char* rval_type) {
    if (strcmp(lval_type, "undefined") == 0 || strcmp(rval_type, "undefined") == 0) return 1; // Avoid cascading errors
    if (strcmp(lval_type, rval_type) == 0) return 1;
    if (strcmp(lval_type, "float") == 0 && strcmp(rval_type, "int") == 0) return 1; // Widening is OK
    return 0;
}

// Returns 1 if the type is numeric (int or float)
int is_numeric(char* type) {
    if (type == NULL) return 0;
    return strcmp(type, "int") == 0 || strcmp(type, "float") == 0;
}

// Returns the resulting type after numeric promotion (e.g., int + float = float)
char* get_promoted_type(char* type1, char* type2) {
    if (!is_numeric(type1) || !is_numeric(type2)) return "undefined";
    if (strcmp(type1, "float") == 0 || strcmp(type2, "float") == 0) return "float";
    return "int";
}

// --- Symbol Table Functions ---

void print_table_to_file(SymbolTable* table, FILE* file) {
    if (!table || !file) return;
    fprintf(file, "--- Scope: %d (Parent Scope: %d) ---\n", table->scope, table->parent ? table->parent->scope : -1);
    fprintf(file, "%-20s | %-15s | %s\n", "Name", "Type", "Line Declared");
    fprintf(file, "-----------------------------------------------------\n");
    for (int i = 0; i < table->count; i++) {
        Symbol* s = table->symbols[i];
        fprintf(file, "%-20s | %-15s | %d\n", s->name, s->type, s->line_declared);
    }
    fprintf(file, "\n");
}


void init_symbol_table() {
    current_table = (SymbolTable*)malloc(sizeof(SymbolTable));
    current_table->count = 0;
    current_table->scope = 0;
    current_table->parent = NULL;
    all_tables[table_count++] = current_table; // Add global scope to the list
}

void enter_scope() {
    SymbolTable* new_table = (SymbolTable*)malloc(sizeof(SymbolTable));
    new_table->count = 0;
    new_table->scope = (current_table->scope) + 1;
    new_table->parent = current_table;
    current_table = new_table;
    all_tables[table_count++] = current_table; // Store for later printing
}

void exit_scope() {
    if (current_table->parent != NULL) {
        current_table = current_table->parent;
        // We don't free the table so we can print it at the end
    }
}

// Insert a symbol into the current scope's table
void insert_symbol(char* name, char* type) {
    // Check for re-declaration in the same scope
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
        symbol->scope = current_table->scope;
        symbol->line_declared = yylineno;
        current_table->symbols[current_table->count++] = symbol;
    } else {
        fprintf(stderr, "Error: Symbol table overflow in current scope.\n");
    }
}

// Look for a symbol in the current scope and all parent scopes
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
    return NULL; // Not found
}

// --- Parse Tree Node Functions ---

Node* create_node(char* type, char* value) {
    Node* node = (Node*)malloc(sizeof(Node));
    node->type = strdup(type);
    node->value = (value != NULL) ? strdup(value) : NULL;
    node->data_type = strdup("undefined"); // Default data type
    node->num_children = 0;
    node->children = NULL;
    return node;
}

void add_child(Node* parent, Node* child) {
    if (child == NULL) return;
    parent->num_children++;
    parent->children = (Node**)realloc(parent->children, parent->num_children * sizeof(Node*));
    parent->children[parent->num_children - 1] = child;
}

char* current_decl_type; // Global variable to hold the type during a declaration
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
%type <node> FUNCDECL FUNC_HEADER PARAMLIST PARAM DECLSTATEMENT DECLLIST DECL INITLIST INDEX
%type <node> ASSGN FUNC_CALL ARGLIST
%type <node> M NN

%%

S: STMNTS M { $$ = create_node("PROGRAM", NULL); add_child($$, $1); root = $$; }
 |           { $$ = create_node("PROGRAM", "empty"); root = $$; }
 | error     { $$ = create_node("PROGRAM", "error"); root = $$; }
 ;

STMNTS: STMNTS M A { $$ = $1; if ($3 != NULL) add_child($$, $3); }
      | A M        { $$ = create_node("STATEMENTS", NULL); if ($1 != NULL) add_child($$, $1); }
      ;

A: ASNEXPR ';'                  { $$ = $1; }
 | IF '(' BOOLEXPR ')' M A        { $$ = create_node("IF", NULL); add_child($$, $3); add_child($$, $6); }
 | IF '(' BOOLEXPR ')' M A ELSE NN M A { $$ = create_node("IF_ELSE", NULL); add_child($$, $3); add_child($$, $6); add_child($$, $10); }
 | WHILE M '(' BOOLEXPR ')' M A { $$ = create_node("WHILE", NULL); add_child($$, $4); add_child($$, $7); }
 | DO { enter_scope(); } M A WHILE M '(' BOOLEXPR ')' ';' { $$ = create_node("DO_WHILE", NULL); add_child($$, $4); add_child($$, $8); exit_scope(); }
 | FOR '(' ASNEXPR ';' M BOOLEXPR ';' M ASNEXPR ')' { enter_scope(); } M A { $$ = create_node("FOR", NULL); add_child($$, $3); add_child($$, $6); add_child($$, $9); add_child($$, $13); exit_scope(); }
 | '{' { enter_scope(); } STMNTS '}' { $$ = $3; exit_scope(); }
 | '{' '}'                      { $$ = create_node("BLOCK", "empty"); }
 | EXPR ';'                     { $$ = create_node("EXPR_STMT", NULL); add_child($$, $1); }
 | DECLSTATEMENT                { $$ = $1; }
 | FUNCDECL                     { $$ = $1; }
 | RETURN EXPR ';'              {
                                    has_return_statement = 1;
                                    $$ = create_node("RETURN", NULL); add_child($$, $2);
                                    if (current_function_return_type == NULL) {
                                        fprintf(stderr, "Error at line %d: return statement found outside of a function.\n", yylineno);
                                    } else if (strcmp(current_function_return_type, "void") == 0) {
                                        fprintf(stderr, "Error at line %d: A 'void' function cannot return a value.\n", yylineno);
                                    } else if (!are_types_compatible(current_function_return_type, $2->data_type)) {
                                        fprintf(stderr, "Error at line %d: Incompatible return type. Function expects '%s' but got '%s'.\n", yylineno, current_function_return_type, $2->data_type);
                                    }
                                }
 | RETURN ';'                   {
                                    has_return_statement = 1;
                                    $$ = create_node("RETURN", "empty");
                                    if (current_function_return_type == NULL) {
                                        fprintf(stderr, "Error at line %d: return statement found outside of a function.\n", yylineno);
                                    } else if (strcmp(current_function_return_type, "void") != 0) {
                                        fprintf(stderr, "Error at line %d: Non-void function must return a value of type '%s'.\n", yylineno, current_function_return_type);
                                    }
                                }
 | BREAK ';'                    { $$ = create_node("BREAK", NULL); }
 | CONTINUE ';'                 { $$ = create_node("CONTINUE", NULL); }
 | ';'                          { $$ = create_node("EMPTY_STMT", NULL); }
 ;

FUNC_HEADER: TYPE IDEN '(' PARAMLIST ')' {
                 $$ = create_node("FUNC_HEADER", NULL);
                 add_child($$, $1); // TYPE node
                 Node* iden_node = create_node("IDEN_VAL", $2); // Use different type to avoid confusion
                 add_child($$, iden_node);
                 add_child($$, $4); // PARAMLIST node
             }
           ;

FUNCDECL: FUNC_HEADER ';' {
              // This is a function prototype
              Node* header = $1;
              Node* type_node = header->children[0];
              Node* iden_node = header->children[1];
              insert_symbol(iden_node->value, type_node->value);
              
              $$ = create_node("FUNC_DECL", iden_node->value);
              add_child($$, type_node);
              add_child($$, header->children[2]); // PARAMLIST
          }
        | FUNC_HEADER '{' {
              // This is the start of a function definition
              Node* header = $1;
              Node* type_node = header->children[0];
              Node* iden_node = header->children[1];
              Node* params_node = header->children[2];

              // Check for re-declaration or conflicting types
              Symbol* s = lookup_symbol(iden_node->value);
              if (s != NULL && s->scope == current_table->scope) {
                  if (strcmp(s->type, type_node->value) != 0) {
                       fprintf(stderr, "Error at line %d: Conflicting return types for function '%s'. Previous declaration was '%s'.\n", yylineno, iden_node->value, s->type);
                  }
              } else {
                   insert_symbol(iden_node->value, type_node->value);
              }
              
              current_function_return_type = type_node->value;
              has_return_statement = 0;
              
              enter_scope();
              add_params_to_scope(params_node); // Add params to the new scope
          } STMNTS '}' {
              // End of function definition
              if (strcmp(current_function_return_type, "void") != 0 && !has_return_statement) {
                  fprintf(stderr, "Error at line %d: Missing return statement in non-void function.\n", yylineno);
              }
              exit_scope();
              current_function_return_type = NULL;
              
              $$ = create_node("FUNC_DEF", $1->children[1]->value);
              add_child($$, $1->children[0]); // TYPE
              add_child($$, $1->children[2]); // PARAMLIST
              add_child($$, $4); // STMNTS
          }
        ;


PARAMLIST: PARAM ',' PARAMLIST { $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); add_child($$, $3); }
         | PARAM               { $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); }
         |                     { $$ = create_node("PARAM_LIST", "empty"); }
         ;

PARAM: TYPE IDEN {
        // Symbol insertion is now handled by FUNCDECL rule
        $$ = create_node("PARAM", $2);
        add_child($$, $1);
        $$->data_type = $1->value;
     }
     | TYPE IDEN INDEX {
        // Symbol insertion is now handled by FUNCDECL rule
        char array_type[50];
        sprintf(array_type, "array(%s)", $1->value);
        $$ = create_node("PARAM_ARRAY", $2);
        add_child($$, $1);
        add_child($$, $3);
        $$->data_type = strdup(array_type);
     }
     ;

DECLSTATEMENT: TYPE DECLLIST ';' {
                 $$ = create_node("DECL_STMT", NULL);
                 add_child($$, $1);
                 add_child($$, $2);
               }
             ;

DECLLIST: DECL ',' DECLLIST { $$ = $3; add_child($$, $1); }
        | DECL              { $$ = create_node("DECL_LIST", NULL); add_child($$, $1); }
        ;

DECL: IDEN {
        insert_symbol($1, current_decl_type);
        $$ = create_node("VAR_DECL", $1);
        $$->data_type = strdup(current_decl_type);
      }
    | IDEN '=' EXPR {
        insert_symbol($1, current_decl_type);
        if (!are_types_compatible(current_decl_type, $3->data_type)) {
            fprintf(stderr, "Error at line %d: Incompatible types in initialization. Cannot assign '%s' to variable of type '%s'\n", yylineno, $3->data_type, current_decl_type);
        }
        $$ = create_node("VAR_INIT", $1);
        add_child($$, $3);
        $$->data_type = strdup(current_decl_type);
      }
    | IDEN INDEX {
        char array_type[50];
        sprintf(array_type, "array(%s)", current_decl_type);
        insert_symbol($1, array_type);
        $$ = create_node("ARRAY_DECL", $1);
        add_child($$, $2);
      }
    | IDEN INDEX '=' '{' INITLIST '}' {
        char array_type[50];
        sprintf(array_type, "array(%s)", current_decl_type);
        insert_symbol($1, array_type);
        $$ = create_node("ARRAY_INIT", $1);
        add_child($$, $2);
        add_child($$, $5);
      }
    ;

INITLIST: INITLIST ',' EXPR { $$ = $1; add_child($$, $3); }
        | EXPR              { $$ = create_node("INIT_LIST", NULL); add_child($$, $1); }
        ;

INDEX: '[' EXPR ']'       {
        if(strcmp($2->data_type, "int") != 0) {
            fprintf(stderr, "Error at line %d: Array index must be an integer, not '%s'\n", yylineno, $2->data_type);
        }
        $$ = create_node("INDEX", NULL); add_child($$, $2);
      }
     | '[' EXPR ']' INDEX {
        if(strcmp($2->data_type, "int") != 0) {
            fprintf(stderr, "Error at line %d: Array index must be an integer, not '%s'\n", yylineno, $2->data_type);
        }
        $$ = create_node("INDEX", NULL); add_child($$, $2); add_child($$, $4);
      }
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
            fprintf(stderr, "Error at line %d: Variable '%s' not defined\n", yylineno, $1);
            $$ = create_node("IDEN", $1);
        } else {
            $$ = create_node("IDEN", $1);
            $$->data_type = strdup(s->type);
        }
      }
    | IDEN INDEX {
        Symbol* s = lookup_symbol($1);
        char base_type[50] = "undefined";
        if (s == NULL) {
            fprintf(stderr, "Error at line %d: Array '%s' not defined\n", yylineno, $1);
        } else {
             // Extract base type e.g., from "array(int)" to "int"
            sscanf(s->type, "array(%[^)])", base_type);
        }
        $$ = create_node("ARRAY_ACCESS", $1);
        add_child($$, $2);
        $$->data_type = strdup(base_type);
      }
    ;

ASNEXPR: LVAL ASSGN EXPR {
           if (!are_types_compatible($1->data_type, $3->data_type)) {
               fprintf(stderr, "Error at line %d: Type mismatch in assignment. Cannot assign '%s' to '%s'\n", yylineno, $3->data_type, $1->data_type);
           }
           $$ = create_node("ASSIGN", NULL);
           add_child($$, $1);
           add_child($$, $2);
           add_child($$, $3);
         }
       ;

BOOLEXPR: BOOLEXPR OR M BOOLEXPR   { $$ = create_node("BOOL_OP", "||"); add_child($$, $1); add_child($$, $4); $$->data_type = "bool"; }
        | BOOLEXPR AND M BOOLEXPR  { $$ = create_node("BOOL_OP", "&&"); add_child($$, $1); add_child($$, $4); $$->data_type = "bool"; }
        | '!' BOOLEXPR             { $$ = create_node("BOOL_OP", "!"); add_child($$, $2); $$->data_type = "bool"; }
        | '(' BOOLEXPR ')'         { $$ = $2; }
        | EXPR LT EXPR             { if(strcmp($1->data_type, $3->data_type) != 0 && strcmp($1->data_type, "undefined") != 0 && strcmp($3->data_type, "undefined") != 0) fprintf(stderr, "Error at line %d: Incompatible types for operator '<'. Operands must be of the same type, but are '%s' and '%s'.\n", yylineno, $1->data_type, $3->data_type); $$ = create_node("REL_OP", "<"); add_child($$, $1); add_child($$, $3); $$->data_type = "bool"; }
        | EXPR GT EXPR             { if(strcmp($1->data_type, $3->data_type) != 0 && strcmp($1->data_type, "undefined") != 0 && strcmp($3->data_type, "undefined") != 0) fprintf(stderr, "Error at line %d: Incompatible types for operator '>'. Operands must be of the same type, but are '%s' and '%s'.\n", yylineno, $1->data_type, $3->data_type); $$ = create_node("REL_OP", ">"); add_child($$, $1); add_child($$, $3); $$->data_type = "bool"; }
        | EXPR EQ EXPR             { if(strcmp($1->data_type, $3->data_type) != 0 && strcmp($1->data_type, "undefined") != 0 && strcmp($3->data_type, "undefined") != 0) fprintf(stderr, "Error at line %d: Incompatible types for operator '=='. Operands must be of the same type, but are '%s' and '%s'.\n", yylineno, $1->data_type, $3->data_type); $$ = create_node("REL_OP", "=="); add_child($$, $1); add_child($$, $3); $$->data_type = "bool"; }
        | EXPR NE EXPR             { if(strcmp($1->data_type, $3->data_type) != 0 && strcmp($1->data_type, "undefined") != 0 && strcmp($3->data_type, "undefined") != 0) fprintf(stderr, "Error at line %d: Incompatible types for operator '!='. Operands must be of the same type, but are '%s' and '%s'.\n", yylineno, $1->data_type, $3->data_type); $$ = create_node("REL_OP", "!="); add_child($$, $1); add_child($$, $3); $$->data_type = "bool"; }
        | EXPR LE EXPR             { if(strcmp($1->data_type, $3->data_type) != 0 && strcmp($1->data_type, "undefined") != 0 && strcmp($3->data_type, "undefined") != 0) fprintf(stderr, "Error at line %d: Incompatible types for operator '<='. Operands must be of the same type, but are '%s' and '%s'.\n", yylineno, $1->data_type, $3->data_type); $$ = create_node("REL_OP", "<="); add_child($$, $1); add_child($$, $3); $$->data_type = "bool"; }
        | EXPR GE EXPR             { if(strcmp($1->data_type, $3->data_type) != 0 && strcmp($1->data_type, "undefined") != 0 && strcmp($3->data_type, "undefined") != 0) fprintf(stderr, "Error at line %d: Incompatible types for operator '>='. Operands must be of the same type, but are '%s' and '%s'.\n", yylineno, $1->data_type, $3->data_type); $$ = create_node("REL_OP", ">="); add_child($$, $1); add_child($$, $3); $$->data_type = "bool"; }
        | TR                       { $$ = create_node("BOOL_CONST", "true"); $$->data_type = "bool"; }
        | FL                       { $$ = create_node("BOOL_CONST", "false"); $$->data_type = "bool"; }
        ;

EXPR: EXPR '+' EXPR {
        if(!is_numeric($1->data_type) || !is_numeric($3->data_type)) fprintf(stderr, "Error at line %d: Operands for '+' must be numeric.\n", yylineno);
        $$ = create_node("BIN_OP", "+"); add_child($$, $1); add_child($$, $3); $$->data_type = get_promoted_type($1->data_type, $3->data_type);
      }
    | EXPR '-' EXPR {
        if(!is_numeric($1->data_type) || !is_numeric($3->data_type)) fprintf(stderr, "Error at line %d: Operands for '-' must be numeric.\n", yylineno);
        $$ = create_node("BIN_OP", "-"); add_child($$, $1); add_child($$, $3); $$->data_type = get_promoted_type($1->data_type, $3->data_type);
      }
    | EXPR '*' EXPR {
        if(!is_numeric($1->data_type) || !is_numeric($3->data_type)) fprintf(stderr, "Error at line %d: Operands for '*' must be numeric.\n", yylineno);
        $$ = create_node("BIN_OP", "*"); add_child($$, $1); add_child($$, $3); $$->data_type = get_promoted_type($1->data_type, $3->data_type);
      }
    | EXPR '/' EXPR {
        if(!is_numeric($1->data_type) || !is_numeric($3->data_type)) fprintf(stderr, "Error at line %d: Operands for '/' must be numeric.\n", yylineno);
        $$ = create_node("BIN_OP", "/"); add_child($$, $1); add_child($$, $3); $$->data_type = get_promoted_type($1->data_type, $3->data_type);
      }
    | EXPR '%' EXPR {
        if(strcmp($1->data_type, "int") != 0 || strcmp($3->data_type, "int") != 0) fprintf(stderr, "Error at line %d: Operands for '%%' must be integers.\n", yylineno);
        $$ = create_node("BIN_OP", "%"); add_child($$, $1); add_child($$, $3); $$->data_type = "int";
      }
    | BOOLEXPR '?' EXPR ':' EXPR {
        if(strcmp($3->data_type, $5->data_type) != 0) fprintf(stderr, "Error at line %d: Type mismatch in ternary operator branches ('%s' and '%s').\n", yylineno, $3->data_type, $5->data_type);
        $$ = create_node("TERNARY_OP", NULL); add_child($$, $1); add_child($$, $3); add_child($$, $5); $$->data_type = $3->data_type;
      }
    | FUNC_CALL     { $$ = $1; }
    | TERM          { $$ = $1; }
    | '-' EXPR %prec UMINUS {
        if(!is_numeric($2->data_type)) fprintf(stderr, "Error at line %d: Unary minus operator requires a numeric type, not '%s'.\n", yylineno, $2->data_type);
        $$ = create_node("UN_OP", "-"); add_child($$, $2); $$->data_type = strdup($2->data_type);
      }
    ;

FUNC_CALL: IDEN '(' ARGLIST ')' {
            Symbol* s = lookup_symbol($1);
            $$ = create_node("FUNC_CALL", $1);
            add_child($$, $3);
            if (s == NULL) {
                fprintf(stderr, "Error at line %d: Function '%s' is not defined.\n", yylineno, $1);
                $$->data_type = strdup("undefined");
            } else {
                $$->data_type = strdup(s->type); // The 'type' of the function symbol is its return type.
            }
         }
         ;

ARGLIST: EXPR ',' ARGLIST { $$ = $3; add_child($$, $1); }
       | EXPR            { $$ = create_node("ARG_LIST", NULL); add_child($$, $1); }
       |                 { $$ = create_node("ARG_LIST", "empty"); }
       ;

TERM: LVAL { $$ = $1; }
    | NUM  { $$ = create_node("NUM", $1); $$->data_type = (strchr($1, '.') ? strdup("float") : strdup("int")); }
    | CHR  { $$ = create_node("CHAR_LIT", $1); $$->data_type = strdup("char"); }
    | STR  { $$ = create_node("STRING_LIT", $1); $$->data_type = strdup("string"); }
    | '(' EXPR ')' { $$ = $2; }
    | LVAL INC {
        if(!is_numeric($1->data_type)) fprintf(stderr, "Error at line %d: Cannot increment non-numeric type '%s'.\n", yylineno, $1->data_type);
        $$ = create_node("POST_INC", "++"); add_child($$, $1); $$->data_type = $1->data_type;
      }
    | LVAL DEC {
        if(!is_numeric($1->data_type)) fprintf(stderr, "Error at line %d: Cannot decrement non-numeric type '%s'.\n", yylineno, $1->data_type);
        $$ = create_node("POST_DEC", "--"); add_child($$, $1); $$->data_type = $1->data_type;
      }
    | INC LVAL {
        if(!is_numeric($2->data_type)) fprintf(stderr, "Error at line %d: Cannot increment non-numeric type '%s'.\n", yylineno, $2->data_type);
        $$ = create_node("PRE_INC", "++"); add_child($$, $2); $$->data_type = $2->data_type;
      }
    | DEC LVAL {
        if(!is_numeric($2->data_type)) fprintf(stderr, "Error at line %d: Cannot decrement non-numeric type '%s'.\n", yylineno, $2->data_type);
        $$ = create_node("PRE_DEC", "--"); add_child($$, $2); $$->data_type = $2->data_type;
      }
    ;

/* Markers */
M:  { $$ = NULL; }
NN: { $$ = NULL; }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    }
    
    yylineno = 1; // Initialize line number
    current_function_return_type = NULL; // Initialize
    has_return_statement = 0;
    init_symbol_table(); // Initialize the global symbol table
    yyparse();

    if (root != NULL) {
        printf("\n--- Parse Tree ---\n");
        print_tree(root, 0);
        
        FILE *output_file = fopen("parser_output.txt", "w");
        if (output_file) {
            fprintf(output_file, "--- Parse Tree ---\n");
            write_tree_to_file(root, output_file, 0);
            fclose(output_file);
            printf("\nParse tree also written to parser_output.txt\n");
        }
    }

    // Print all symbol tables to a file
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
    for (int i = 0; i < level; i++) {
        printf("  ");
    }
    printf("%s", node->type);
    if (node->value != NULL) {
        printf(" (%s)", node->value);
    }
    printf(" [type: %s]\n", node->data_type);
    for (int i = 0; i < node->num_children; i++) {
        print_tree(node->children[i], level + 1);
    }
}

void write_tree_to_file(Node* node, FILE* file, int level) {
    if (node == NULL || file == NULL) return;
    for (int i = 0; i < level; i++) {
        fprintf(file, "  ");
    }
    fprintf(file, "%s", node->type);
    if (node->value != NULL) {
        fprintf(file, " (%s)", node->value);
    }
    fprintf(file, " [type: %s]\n", node->data_type);
    for (int i = 0; i < node->num_children; i++) {
        write_tree_to_file(node->children[i], file, level + 1);
    }
}
