%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern FILE* yyin;
extern int yylineno; 
int yydebug = 0;

// Forward declarations
void yyerror(const char* s);
int yylex();
%}

%%
%left OR AND
%left LT GT LE GE EQ NE
%left '+' '-'
%left '*' '/' '%'
%right '=' PASN MASN DASN SASN
%right UMINUS INC DEC
%right '?' ':'                /* ternary operator*/
%token RETURN BREAK CONTINUE
%token DO 
%token STRING STR             /* STR is literal, STRING token is for type */
%token TR FL                  /* boolean literals */
%token CLASS
%token PUBLIC PRIVATE PROTECTED
%token ABSTRACT


S: STMNTS M 
 | 
 | error 
;

STMNTS: STMNTS M A
 | A M
;

A: ASNEXPR ';'
 | ASNEXPR error 
 | IF '(' BOOLEXPR ')' M A
 | IF '(' BOOLEXPR ')' M A ELSE NN M A
 //| IF BOOLEXPR ')' M A ELSE NN M A      /* error handling */
 //| EXPR error 
 //| WHILE M '(' BOOLEXPR ')' M A
 //| WHILE M BOOLEXPR ')' M A             /*error handling */
 | DO M A WHILE M '(' BOOLEXPR ')' ';'  
 /* Fully updated FOR rule */
 | FOR '(' OPT_ASNEXPR ';' M OPT_BOOLEXPR ';' M OPT_EXPR ')' M A
 | '{' STMNTS '}'
 | '{' '}'
 | EXPR ';'
 | DECLSTATEMENT
 | FUNCDECL
 | CLASSDECL
 | ABSTRACTCLASS
 | RETURN EXPR ';'
 | RETURN ';'             
 | BREAK ';'            
 | CONTINUE ';'           
 | ';'                   
;

/* FOR loop optional parts */
OPT_ASNEXPR: ASNEXPR
 | DECLSTATEMENT
 | /* empty */
;

OPT_BOOLEXPR: BOOLEXPR
 | /* empty */
;

OPT_EXPR: EXPR
 | /* empty */
;

FUNCDECL: /*TYPE IDEN '(' PARAMLIST ')' ';' */ /* Function Prototype *//* due to conflict*/
 | TYPE IDEN '(' PARAMLIST ')' '{' STMNTS '}'
;

PARAMLIST: PARAM ',' PARAMLIST
 | PARAM
 | /* empty */
;

PARAM: TYPE IDEN
 | TYPE IDEN INDEX
;

DECLSTATEMENT: TYPE DECLLIST ';'
 //| TYPE DECLLIST error 
;

DECLLIST: DECL ',' DECLLIST
 | DECL
;

DECL: IDEN
 | IDEN '=' EXPR
 | IDEN INDEX
 | IDEN INDEX '=' '{' INITLIST '}'   /*initializing array*/
;

INITLIST: INITLIST ',' EXPR
 | EXPR
;

INDEX: '[' EXPR ']'
 | '[' EXPR ']' INDEX
;

TYPE: INT
 | FLOAT
 | CHAR
 | VOID
 | STRING
;

ASSGN: '=' | PASN | MASN | DASN | SASN ;

LVAL: IDEN
    | IDEN INDEX
;

/* ASNEXPR can be either an assignment or just a simple expression like i++ */
ASNEXPR: LVAL ASSGN EXPR
 | EXPR
;

BOOLEXPR:
  BOOLEXPR OR M BOOLEXPR
 | BOOLEXPR AND M BOOLEXPR
 | '!' BOOLEXPR
 | '(' BOOLEXPR ')'
 | EXPR LT EXPR
 | EXPR GT EXPR
 | EXPR EQ EXPR
 | EXPR NE EXPR
 | EXPR LE EXPR
 | EXPR GE EXPR
 | TR
 | FL
;

EXPR: EXPR '+' EXPR
 | EXPR '-' EXPR
 | EXPR '*' EXPR
 | EXPR '/' EXPR
 | EXPR '%' EXPR
 | BOOLEXPR '?' EXPR ':' EXPR        /*ternary-condition*/
 | FUNC_CALL                  
 | TERM
 | '-' EXPR %prec UMINUS
;

FUNC_CALL: IDEN '(' ARGLIST ')'
;

ARGLIST: EXPR ',' ARGLIST
 | EXPR
 | /* empty */
;

LVALIST: LVAL
       | LVAL ',' LVALIST
;

TERM: IDEN
 | IDEN INDEX
 | NUM
 | STR
--  | TR
--  | FL removed  due to reduce reduc conflicts;
 | '(' EXPR ')'
 | LVAL INC
 | LVAL DEC//
 | INC LVAL
 | DEC LVAL
;


/* OOPS */

/* Encapsulation */
CLASSDECL: CLASS IDEN OPT_INHERIT '{' CLASSBODY '}' ';' ;

OPT_INHERIT: ':' INHERITLIST
           | /* empty */
;

INHERITLIST: ACCESS IDEN
           | ACCESS IDEN ',' INHERITLIST
;

CLASSBODY: CLASSBODY CLASSMEMBER
         | CLASSMEMBER
;

CLASSMEMBER: ACCESS MODIFIER_DECL
           | ACCESS FUNCDECL
           | ACCESS ABSTRACTFUNC
           | ACCESS CONSTRUCTOR
           | ACCESS DESTRUCTOR
;

ACCESS: PUBLIC
      | PRIVATE
      | PROTECTED
      | /* empty */
;

MODIFIER_DECL: TYPE DECLLIST ';' ;

/* Constructor */

CONSTRUCTOR: IDEN '(' PARAMLIST ')' '{' STMNTS '}' ';' ;

/* Destrcutor */

DESTRUCTOR: '~' IDEN '(' ')' '{' STMNTS '}' ';' ;


/* Abstraction */
ABSTRACTCLASS: ABSTRACT CLASS IDEN OPT_INHERIT '{' ABSTRACTBODY '}' ';' ;

ABSTRACTBODY: ABSTRACTBODY ABSTRACTMEMBER
            | ABSTRACTMEMBER
;

ABSTRACTMEMBER: ACCESS ABSTRACTFUNC ;

ABSTRACTFUNC: TYPE IDEN '(' PARAMLIST ')' ';' ;


/* Markers */
M:
NN: /*Marker to handle else part*/

%%

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("fopen");
            return 1;
        }
    }
    yyparse();
    return 0;
}