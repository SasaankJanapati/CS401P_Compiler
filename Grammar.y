%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Forward declarations
void yyerror(const char* s);
int yylex();
extern int yylineno;
extern FILE* yyin;

// Simple AST Node Structure
typedef struct Node {
    char* type;
    char* value;
    int num_children;
    struct Node** children;
} Node;

// AST helper functions
Node* create_node(char* type, char* value);
void add_child(Node* parent, Node* child);
void print_tree(Node* node, int level);

Node* root = NULL;
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
 | IF '(' BOOLEXPR ')' M A        { $$ = create_node("IF", NULL); add_child($$, $3); add_child($$, $6); }
 | IF '(' BOOLEXPR ')' M A ELSE NN M A { $$ = create_node("IF_ELSE", NULL); add_child($$, $3); add_child($$, $6); add_child($$, $10); }
 | WHILE M '(' BOOLEXPR ')' M A { $$ = create_node("WHILE", NULL); add_child($$, $4); add_child($$, $7); }
 | DO M A WHILE M '(' BOOLEXPR ')' ';' { $$ = create_node("DO_WHILE", NULL); add_child($$, $3); add_child($$, $7); }
 | FOR '(' OPT_ASNEXPR ';' M OPT_BOOLEXPR ';' M OPT_EXPR ')' M A
   {
     $$ = create_node("FOR", NULL);
     add_child($$, $3);
     add_child($$, $6);
     add_child($$, $9);
     add_child($$, $12);
   }
 | '{' STMNTS '}'               { $$ = $2; }
 | '{' '}'                      { $$ = create_node("BLOCK", "empty"); }
 | EXPR ';'                     { $$ = create_node("EXPR_STMT", NULL); add_child($$, $1); }
 | DECLSTATEMENT                { $$ = $1; }
 | OBJECTDECLSTMT               { $$ = $1; }
 | FUNCDECL                     { $$ = $1; }
 | CLASSDECL                    { $$ = $1; }
 | ABSTRACTCLASS                { $$ = $1; }
 | RETURN EXPR ';'              { $$ = create_node("RETURN", NULL); add_child($$, $2); }
 | RETURN ';'                   { $$ = create_node("RETURN", "empty"); }
 | BREAK ';'                    { $$ = create_node("BREAK", NULL); }
 | CONTINUE ';'                 { $$ = create_node("CONTINUE", NULL); }
 | ';'                          { $$ = create_node("EMPTY_STMT", NULL); }
 ;

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
FUNCDECL: TYPE IDEN '(' PARAMLIST ')' '{' STMNTS '}' {
              $$ = create_node("FUNC_DEF", $2);
              add_child($$, $1);
              add_child($$, $4);
              add_child($$, $7);
          }
        ;
PARAMLIST: PARAM ',' PARAMLIST { $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); add_child($$, $3); }
         | PARAM               { $$ = create_node("PARAM_LIST", NULL); add_child($$, $1); }
         |                     { $$ = create_node("PARAM_LIST", "empty"); }
         ;
PARAM: TYPE IDEN {
        $$ = create_node("PARAM", $2);
        add_child($$, $1);
     }
     | TYPE IDEN INDEX {
        $$ = create_node("PARAM_ARRAY", $2);
        add_child($$, $1);
        add_child($$, $3);
     }
     | IDEN IDEN {
        $$ = create_node("PARAM", $2);
        add_child($$, $1);
     }
     | IDEN IDEN INDEX {
        $$ = create_node("PARAM_ARRAY", $2);
        add_child($$, $1);
        add_child($$, $3);
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
        $$ = create_node("VAR_DECL", $1);
      }
    | IDEN '=' EXPR {
        $$ = create_node("VAR_INIT", $1);
        add_child($$, $3);
      }
    | IDEN INDEX {
        $$ = create_node("ARRAY_DECL", $1);
        add_child($$, $2);
      }
    | IDEN INDEX '=' '{' INITLIST '}' {
        $$ = create_node("ARRAY_INIT", $1);
        add_child($$, $2);
        add_child($$, $5);
      }
    ;
INITLIST: INITLIST ',' EXPR { $$ = $1; add_child($$, $3); }
        | EXPR              { $$ = create_node("INIT_LIST", NULL); add_child($$, $1); }
        ;
INDEX: '[' EXPR ']' { $$ = create_node("INDEX", NULL); add_child($$, $2); }
     | '[' EXPR ']' INDEX { $$ = create_node("INDEX", NULL); add_child($$, $2); add_child($$, $4); }
     ;
TYPE: INT    { $$ = create_node("TYPE", "int"); }
    | FLOAT  { $$ = create_node("TYPE", "float"); }
    | CHAR   { $$ = create_node("TYPE", "char"); }
    | VOID   { $$ = create_node("TYPE", "void"); }
    | STRING { $$ = create_node("TYPE", "string"); }
    ;
ASSGN: '='  { $$ = create_node("ASSIGN_OP", "="); }
     | PASN { $$ = create_node("ASSIGN_OP", "+="); }
     | MASN { $$ = create_node("ASSIGN_OP", "-="); }
     | DASN { $$ = create_node("ASSIGN_OP", "/="); }
     | SASN { $$ = create_node("ASSIGN_OP", "*="); }
     ;
LVAL: IDEN { $$ = create_node("IDEN", $1); }
    | IDEN INDEX {
        $$ = create_node("ARRAY_ACCESS", $1);
        add_child($$, $2);
      }
    | MEMBERACCESS { $$ = $1; }
    ;
ASNEXPR: LVAL ASSGN EXPR {
           $$ = create_node("ASSIGN", NULL);
           add_child($$, $1);
           add_child($$, $2);
           add_child($$, $3);
         }
        | LVAL '=' NEW IDEN '(' ARGLIST ')'
        {
            $$ = create_node("NEW_OBJ_ASSIGN", NULL);
            add_child($$, $1);
            Node* assign_op = create_node("ASSIGN_OP", "=");
            add_child($$, assign_op);
            Node* new_node = create_node("NEW_OBJ", NULL);
            add_child(new_node, create_node("CLASS_NAME", $4));
            add_child(new_node, $6); // ARGLIST
            add_child($$, new_node);
        }
       ;
BOOLEXPR: BOOLEXPR OR M BOOLEXPR   { $$ = create_node("BOOL_OP", "||"); add_child($$, $1); add_child($$, $4); }
        | BOOLEXPR AND M BOOLEXPR  { $$ = create_node("BOOL_OP", "&&"); add_child($$, $1); add_child($$, $4); }
        | '!' '(' BOOLEXPR ')'     { $$ = create_node("BOOL_OP", "!"); add_child($$, $3); }
        | '(' BOOLEXPR ')'         { $$ = $2; }
        | EXPR LT EXPR             { $$ = create_node("REL_OP", "<"); add_child($$, $1); add_child($$, $3); }
        | EXPR GT EXPR             { $$ = create_node("REL_OP", ">"); add_child($$, $1); add_child($$, $3); }
        | EXPR EQ EXPR             { $$ = create_node("REL_OP", "=="); add_child($$, $1); add_child($$, $3); }
        | EXPR NE EXPR             { $$ = create_node("REL_OP", "!="); add_child($$, $1); add_child($$, $3); }
        | EXPR LE EXPR             { $$ = create_node("REL_OP", "<="); add_child($$, $1); add_child($$, $3); }
        | EXPR GE EXPR             { $$ = create_node("REL_OP", ">="); add_child($$, $1); add_child($$, $3); }
        | TR                       { $$ = create_node("BOOL_CONST", "true"); }
        | FL                       { $$ = create_node("BOOL_CONST", "false"); }
        ;
EXPR: EXPR '+' EXPR { $$ = create_node("BIN_OP", "+"); add_child($$, $1); add_child($$, $3); }
    | EXPR '-' EXPR { $$ = create_node("BIN_OP", "-"); add_child($$, $1); add_child($$, $3); }
    | EXPR '*' EXPR { $$ = create_node("BIN_OP", "*"); add_child($$, $1); add_child($$, $3); }
    | EXPR '/' EXPR { $$ = create_node("BIN_OP", "/"); add_child($$, $1); add_child($$, $3); }
    | EXPR '%' EXPR { $$ = create_node("BIN_OP", "%"); add_child($$, $1); add_child($$, $3); }
    | BOOLEXPR '?' EXPR ':' EXPR { $$ = create_node("TERNARY_OP", NULL); add_child($$, $1); add_child($$, $3); add_child($$, $5); }
    | FUNC_CALL     { $$ = $1; }
    | TERM          { $$ = $1; }
    | '-' EXPR %prec UMINUS { $$ = create_node("UN_OP", "-"); add_child($$, $2); }
    ;
FUNC_CALL: IDEN '(' ARGLIST ')' {
            $$ = create_node("FUNC_CALL", $1);
            add_child($$, $3);
         }
         ;
ARGLIST: EXPR ',' ARGLIST { $$ = $3; add_child($$, $1); }
       | EXPR            { $$ = create_node("ARG_LIST", NULL); add_child($$, $1); }
       |                 { $$ = create_node("ARG_LIST", "empty"); }
       ;
TERM: LVAL { $$ = $1; }
    | NUM  { $$ = create_node("NUM", $1); }
    | STR  { $$ = create_node("STRING_LIT", $1); }
    | CHR  { $$ = create_node("CHAR_LIT", $1); }
    | '(' EXPR ')' { $$ = $2; }
    | LVAL INC { $$ = create_node("POST_INC", "++"); add_child($$, $1); }
    | LVAL DEC { $$ = create_node("POST_DEC", "--"); add_child($$, $1); }
    | INC LVAL { $$ = create_node("PRE_INC", "++"); add_child($$, $2); }
    | DEC LVAL { $$ = create_node("PRE_DEC", "--"); add_child($$, $2); }
    ;
CLASSDECL: CLASS IDEN OPT_INHERIT '{' CLASSBODY '}' ';' {
            $$ = create_node("CLASS_DECL", $2);
            add_child($$, $3);
            add_child($$, $5);
           };
OPT_INHERIT: ':' INHERITLIST { $$ = $2; }
           | /* empty */ { $$ = create_node("NO_INHERITANCE", NULL); }
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
         | /* empty */           { $$ = create_node("CLASS_BODY", "empty"); }
         ;
CLASSMEMBER: ACCESS MODIFIER_DECL { $$ = $2; }
           | ACCESS FUNCDECL { $$ = $2; }
           | ACCESS ABSTRACTFUNC { $$ = $2; }
           | ACCESS CONSTRUCTOR { $$ = $2; }
           | ACCESS DESTRUCTOR { $$ = $2; }
           | ACCESS ABSTRACTMEMBER { $$ = $2; }
           | ACCESS OBJECTDECLSTMT { $$ = $2; }
           ;
ACCESS: PUBLIC    { $$ = create_node("ACCESS", "public"); }
      | PRIVATE   { $$ = create_node("ACCESS", "private"); }
      | PROTECTED { $$ = create_node("ACCESS", "protected"); }
      ;
MODIFIER_DECL: TYPE DECLLIST ';' {
                $$ = create_node("MEMBER_DECL", NULL);
                add_child($$, $1);
                add_child($$, $2);
              }
              ;
CONSTRUCTOR: IDEN '(' PARAMLIST ')' '{' STMNTS '}' ';' {
                $$ = create_node("CONSTRUCTOR", $1);
                add_child($$, $3);
                add_child($$, $6);
             }
             ;
DESTRUCTOR: '~' IDEN '(' ')' '{' STMNTS '}' ';' {
                $$ = create_node("DESTRUCTOR", $2);
                add_child($$, $6);
            }
            ;
ABSTRACTCLASS: ABSTRACT CLASS IDEN OPT_INHERIT '{' ABSTRACTBODY '}' ';' {
                $$ = create_node("ABSTRACT_CLASS", $3);
                add_child($$, $4);
                add_child($$, $6);
             }
             ;
ABSTRACTBODY: ABSTRACTBODY ABSTRACTMEMBER { $$ = $1; add_child($$, $2); }
            | ABSTRACTMEMBER             { $$ = create_node("ABSTRACT_BODY", NULL); add_child($$, $1); }
            ;
ABSTRACTMEMBER: ACCESS ABSTRACTFUNC { $$ = $2; }
              ;
ABSTRACTFUNC: ABSTRACT TYPE IDEN '(' PARAMLIST ')' ';' {
                $$ = create_node("ABSTRACT_FUNC", $3);
                add_child($$, $2);
                add_child($$, $5);
              }
              ;
OBJECTDECLSTMT: OBJDECL ';' { $$ = $1; }
               ;
OBJDECL: IDEN IDEN {
            $$ = create_node("OBJ_DECL", $2);
        }
        | IDEN IDEN '=' NEW IDEN '(' ARGLIST ')' {
            $$ = create_node("OBJ_INIT", $2);
            add_child($$, $7);
        }
        | IDEN IDEN INDEX {
            $$ = create_node("OBJ_ARRAY_DECL", $2);
            add_child($$, $3);
        }
         ;
MEMBERACCESS: LVAL '.' IDEN {
                $$ = create_node("MEMBER_VAR_ACCESS", $3);
                add_child($$, $1);
            }
            | LVAL '.' IDEN INDEX {
               $$ = create_node("MEMBER_ARRAY_ACCESS", $3);
               add_child($$, $1);
               add_child($$, $3);
               add_child($$, $4);
            }
            | LVAL '.' FUNC_CALL {
               $$ = create_node("MEMBER_FUNC_ACCESS", $3->value);
               add_child($$, $1);
               add_child($$, $3);
            }
           ;
M:  { $$ = NULL; }
NN: { $$ = NULL; }

%%

// --- Main & Helper Functions ---

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    }
    yylineno = 1;
    yyparse();
    if (root) {
        printf("\n--- Abstract Syntax Tree ---\n");
        print_tree(root, 0);
    }
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}

// --- AST Functions ---

Node* create_node(char* type, char* value) {
    Node* node = (Node*)malloc(sizeof(Node));
    node->type = strdup(type);
    node->value = (value != NULL) ? strdup(value) : NULL;
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

void print_tree(Node* node, int level) {
    if (node == NULL) return;
    for (int i = 0; i < level; i++) printf("  ");
    printf("%s", node->type);
    if (node->value != NULL) printf(" (%s)", node->value);
    printf("\n");
    for (int i = 0; i < node->num_children; i++) {
        print_tree(node->children[i], level + 1);
    }
}