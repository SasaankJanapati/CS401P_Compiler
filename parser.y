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

S: STMNTS { printf("Reduced S -> STMNTS\n"); $$ = create_node("S", NULL); add_child($$, $1); root = $$; }
 | STMNTS M MEOF { printf("Reduced S -> STMNTS M MEOF\n"); $$ = create_node("S", NULL); add_child($$, $1); root = $$; }
 | MEOF { printf("Reduced S -> MEOF\n"); $$ = create_node("S", "empty"); root = $$; }
 | error MEOF { printf("Reduced S -> error MEOF\n"); $$ = create_node("S", "error"); root = $$; }
 ;

STMNTS: STMNTS M A { printf("Reduced STMNTS -> STMNTS M A\n"); $$ = $1; add_child($$, $3); }
      | A M { printf("Reduced STMNTS -> A M\n"); $$ = create_node("STMNTS", NULL); add_child($$, $1); }
      ;

A: ASNEXPR ';' { printf("Reduced A -> ASNEXPR ;\n"); $$ = create_node("ASN_STMT", NULL); add_child($$, $1); }
 | IF '(' BOOLEXPR ')' M A { printf("Reduced A -> IF ( BOOLEXPR ) M A\n"); $$ = create_node("IF_STMT", NULL); add_child($$, $3); add_child($$, $6); }
 | IF '(' BOOLEXPR ')' M A ELSE NN M A { printf("Reduced A -> IF ( BOOLEXPR ) M A ELSE NN M A\n"); $$ = create_node("IF_ELSE_STMT", NULL); add_child($$, $3); add_child($$, $6); add_child($$, $10); }
 | WHILE M '(' BOOLEXPR ')' M A { printf("Reduced A -> WHILE M ( BOOLEXPR ) M A\n"); $$ = create_node("WHILE_STMT", NULL); add_child($$, $4); add_child($$, $7); }
 | FOR '(' ASNEXPR ';' M BOOLEXPR ';' M ASNEXPR ')' M A { printf("Reduced A -> FOR (...)\n"); $$ = create_node("FOR_STMT", NULL); add_child($$, $3); add_child($$, $6); add_child($$, $9); add_child($$, $12); }
 | '{' STMNTS '}' { printf("Reduced A -> { STMNTS }\n"); $$ = $2; }
 | '{' '}' { printf("Reduced A -> { }\n"); $$ = create_node("BLOCK", "empty"); }
 | EXPR ';' { printf("Reduced A -> EXPR ;\n"); $$ = create_node("EXPR_STMT", NULL); add_child($$, $1); }
 | DECLSTATEMENT { printf("Reduced A -> DECLSTATEMENT\n"); $$ = $1; }
 | FUNCDECL { printf("Reduced A -> FUNCDECL\n"); $$ = $1; }
 | RETURN EXPR ';' { printf("Reduced A -> RETURN EXPR ;\n"); $$ = create_node("RETURN_STMT", NULL); add_child($$, $2); }
 | RETURN ';' { printf("Reduced A -> RETURN ;\n"); $$ = create_node("RETURN_STMT", "empty"); }
 | BREAK ';' { printf("Reduced A -> BREAK ;\n"); $$ = create_node("BREAK_STMT", NULL); }
 | CONTINUE ';' { printf("Reduced A -> CONTINUE ;\n"); $$ = create_node("CONTINUE_STMT", NULL); }
 | ';' { printf("Reduced A -> ;\n"); $$ = create_node("EMPTY_STMT", NULL); }
 ;

/* Functions */
FUNCDECL: TYPE IDEN '(' PARAMLIST ')' ';' { printf("Reduced FUNCDECL -> TYPE IDEN ( PARAMLIST ) ;\n"); $$ = create_node("FUNC_DECL", $2); add_child($$, $1); add_child($$, $4); }
        | TYPE IDEN '(' PARAMLIST ')' '{' STMNTS '}' { printf("Reduced FUNCDECL -> TYPE IDEN ( PARAMLIST ) { STMNTS }\n"); $$ = create_node("FUNC_DEF", $2); add_child($$, $1); add_child($$, $4); add_child($$, $7); }
        ;

PARAMLIST: PARAM ',' PARAMLIST { printf("Reduced PARAMLIST -> PARAM , PARAMLIST\n"); $$ = $3; add_child($$, $1); } /* Building list in reverse for convenience */
         | PARAM { printf("Reduced PARAMLIST -> PARAM\n"); $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); }
         | /* empty */ { printf("Reduced PARAMLIST -> empty\n"); $$ = create_node("PARAM_LIST", "empty"); }
         ;

PARAM: TYPE IDEN { printf("Reduced PARAM -> TYPE IDEN\n"); $$ = create_node("PARAM", $2); add_child($$, $1); }
     | TYPE IDEN INDEX { printf("Reduced PARAM -> TYPE IDEN INDEX\n"); Node* n = create_node("PARAM_ARRAY", $2); add_child(n, $1); add_child(n, $3); $$ = n; }
     ;

/* Declarations */
DECLSTATEMENT: TYPE DECLLIST ';' { printf("Reduced DECLSTATEMENT -> TYPE DECLLIST ;\n"); $$ = create_node("DECL_STMT", NULL); add_child($$, $1); add_child($$, $2); }
             ;

DECLLIST: DECL ',' DECLLIST { printf("Reduced DECLLIST -> DECL , DECLLIST\n"); $$ = $3; add_child($$, $1); } /* Building list in reverse */
        | DECL { printf("Reduced DECLLIST -> DECL\n"); $$ = create_node("DECL_LIST", NULL); add_child($$, $1); }
        ;

DECL: IDEN { printf("Reduced DECL -> IDEN\n"); $$ = create_node("VAR_DECL", $1); }
    | IDEN '=' EXPR { printf("Reduced DECL -> IDEN = EXPR\n"); $$ = create_node("VAR_INIT", $1); add_child($$, $3); }
    | IDEN INDEX { printf("Reduced DECL -> IDEN INDEX\n"); Node* n = create_node("ARRAY_DECL", $1); add_child(n, $2); $$ = n; }
    | IDEN INDEX '=' '{' INITLIST '}' { printf("Reduced DECL -> IDEN INDEX = { INITLIST }\n"); Node* n = create_node("ARRAY_INIT", $1); add_child(n, $2); add_child(n, $5); $$ = n; }
    ;

INITLIST: INITLIST ',' EXPR { printf("Reduced INITLIST -> INITLIST , EXPR\n"); $$ = $1; add_child($$, $3); }
        | EXPR { printf("Reduced INITLIST -> EXPR\n"); $$ = create_node("INIT_LIST", NULL); add_child($$, $1); }
        ;

INDEX: '[' NUM ']' { printf("Reduced INDEX -> [ NUM ]\n"); $$ = create_node("INDEX", $2); }
     | '[' NUM ']' INDEX { printf("Reduced INDEX -> [ NUM ] INDEX\n"); $$ = create_node("INDEX", $2); add_child($$, $4); }
     ;

TYPE: INT { printf("Reduced TYPE -> INT\n"); $$ = create_node("TYPE", "int"); }
    | FLOAT { printf("Reduced TYPE -> FLOAT\n"); $$ = create_node("TYPE", "float"); }
    | CHAR { printf("Reduced TYPE -> CHAR\n"); $$ = create_node("TYPE", "char"); }
    | VOID { printf("Reduced TYPE -> VOID\n"); $$ = create_node("TYPE", "void"); }
    ;

/* Expressions */
ASSGN: '=' { printf("Reduced ASSGN -> =\n"); $$ = create_node("ASSIGN_OP", "="); }
     | PASN { printf("Reduced ASSGN -> PASN\n"); $$ = create_node("ASSIGN_OP", "+="); }
     | MASN { printf("Reduced ASSGN -> MASN\n"); $$ = create_node("ASSIGN_OP", "-="); }
     | DASN { printf("Reduced ASSGN -> DASN\n"); $$ = create_node("ASSIGN_OP", "/="); }
     | SASN { printf("Reduced ASSGN -> SASN\n"); $$ = create_node("ASSIGN_OP", "*="); }
     ;

ASNEXPR: EXPR ASSGN EXPR { printf("Reduced ASNEXPR -> EXPR ASSGN EXPR\n"); $$ = create_node("ASSIGN", NULL); add_child($$, $1); add_child($$, $2); add_child($$, $3); }
       ;

BOOLEXPR: BOOLEXPR OR M BOOLEXPR { printf("Reduced BOOLEXPR -> BOOLEXPR OR M BOOLEXPR\n"); $$ = create_node("BOOL_OP", "||"); add_child($$, $1); add_child($$, $4); }
        | BOOLEXPR AND M BOOLEXPR { printf("Reduced BOOLEXPR -> BOOLEXPR AND M BOOLEXPR\n"); $$ = create_node("BOOL_OP", "&&"); add_child($$, $1); add_child($$, $4); }
        | '!' BOOLEXPR { printf("Reduced BOOLEXPR -> ! BOOLEXPR\n"); $$ = create_node("BOOL_OP", "!"); add_child($$, $2); }
        | '(' BOOLEXPR ')' { printf("Reduced BOOLEXPR -> ( BOOLEXPR )\n"); $$ = $2; }
        | EXPR LT EXPR { printf("Reduced BOOLEXPR -> EXPR LT EXPR\n"); $$ = create_node("REL_OP", "<"); add_child($$, $1); add_child($$, $3); }
        | EXPR GT EXPR { printf("Reduced BOOLEXPR -> EXPR GT EXPR\n"); $$ = create_node("REL_OP", ">"); add_child($$, $1); add_child($$, $3); }
        | EXPR EQ EXPR { printf("Reduced BOOLEXPR -> EXPR EQ EXPR\n"); $$ = create_node("REL_OP", "=="); add_child($$, $1); add_child($$, $3); }
        | EXPR NE EXPR { printf("Reduced BOOLEXPR -> EXPR NE EXPR\n"); $$ = create_node("REL_OP", "!="); add_child($$, $1); add_child($$, $3); }
        | EXPR LE EXPR { printf("Reduced BOOLEXPR -> EXPR LE EXPR\n"); $$ = create_node("REL_OP", "<="); add_child($$, $1); add_child($$, $3); }
        | EXPR GE EXPR { printf("Reduced BOOLEXPR -> EXPR GE EXPR\n"); $$ = create_node("REL_OP", ">="); add_child($$, $1); add_child($$, $3); }
        | TR { printf("Reduced BOOLEXPR -> TR\n"); $$ = create_node("BOOL_CONST", "true"); }
        | FL { printf("Reduced BOOLEXPR -> FL\n"); $$ = create_node("BOOL_CONST", "false"); }
        ;

EXPR: EXPR '+' EXPR { printf("Reduced EXPR -> EXPR + EXPR\n"); $$ = create_node("BIN_OP", "+"); add_child($$, $1); add_child($$, $3); }
    | EXPR '-' EXPR { printf("Reduced EXPR -> EXPR - EXPR\n"); $$ = create_node("BIN_OP", "-"); add_child($$, $1); add_child($$, $3); }
    | EXPR '*' EXPR { printf("Reduced EXPR -> EXPR * EXPR\n"); $$ = create_node("BIN_OP", "*"); add_child($$, $1); add_child($$, $3); }
    | EXPR '/' EXPR { printf("Reduced EXPR -> EXPR / EXPR\n"); $$ = create_node("BIN_OP", "/"); add_child($$, $1); add_child($$, $3); }
    | EXPR '%' EXPR { printf("Reduced EXPR -> EXPR %% EXPR\n"); $$ = create_node("BIN_OP", "%"); add_child($$, $1); add_child($$, $3); }
    | FUNC_CALL { printf("Reduced EXPR -> FUNC_CALL\n"); $$ = $1; }
    | TERM { printf("Reduced EXPR -> TERM\n"); $$ = $1; }
    | '-' EXPR %prec UMINUS { printf("Reduced EXPR -> - EXPR\n"); $$ = create_node("UN_OP", "-"); add_child($$, $2); }
    ;

FUNC_CALL: IDEN '(' ARGLIST ')' { printf("Reduced FUNC_CALL -> IDEN ( ARGLIST )\n"); $$ = create_node("FUNC_CALL", $1); add_child($$, $3); }
         ;

ARGLIST: EXPR ',' ARGLIST { printf("Reduced ARGLIST -> EXPR , ARGLIST\n"); $$ = $3; add_child($$, $1); } /* Building list in reverse */
       | EXPR { printf("Reduced ARGLIST -> EXPR\n"); $$ = create_node("ARG_LIST", NULL); add_child($$, $1); }
       | /* empty */ { printf("Reduced ARGLIST -> empty\n"); $$ = create_node("ARG_LIST", "empty"); }
       ;

TERM: IDEN { printf("Reduced TERM -> IDEN\n"); $$ = create_node("IDEN", $1); }
    | NUM { printf("Reduced TERM -> NUM\n"); $$ = create_node("NUM", $1); }
    | '(' EXPR ')' { printf("Reduced TERM -> ( EXPR )\n"); $$ = $2; }
    | IDEN INC { printf("Reduced TERM -> IDEN INC\n"); $$ = create_node("UN_OP_POST", "++"); add_child($$, create_node("IDEN", $1)); }
    | IDEN DEC { printf("Reduced TERM -> IDEN DEC\n"); $$ = create_node("UN_OP_POST", "--"); add_child($$, create_node("IDEN", $1)); }
    | INC IDEN { printf("Reduced TERM -> INC IDEN\n"); $$ = create_node("UN_OP_PRE", "++"); add_child($$, create_node("IDEN", $2)); }
    | DEC IDEN { printf("Reduced TERM -> DEC IDEN\n"); $$ = create_node("UN_OP_PRE", "--"); add_child($$, create_node("IDEN", $2)); }
    ;

/* Markers */
M: /* empty */ { $$ = NULL; }
NN: /* empty */ { $$ = NULL; }

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

