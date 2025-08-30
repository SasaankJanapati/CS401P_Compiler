%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>
extern YYSTYPE yylval;
%}

%%
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }       /* Added */
"return"        { return RETURN; }    /* Added */
"break"         { return BREAK; }     /* Added */
"continue"      { return CONTINUE; }  /* Added */

"int"           { return INT; }
"float"         { return FLOAT; }
"char"          { return CHAR; }
"void"          { return VOID; }      /* Added */

"true"          { return TR; }
"false"         { return FL; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str_val = strdup(yytext); return IDEN; }
[0-9]+          { yylval.str_val = strdup(yytext); return NUM; }
[0-9]+\.[0-9]+  { yylval.str_val = strdup(yytext); return NUM; }

"+="            { return PASN; }
"-="            { return MASN; }
"/="            { return DASN; }
"*="            { return SASN; }
"||"            { return OR; }
"&&"            { return AND; }
"=="            { return EQ; }
"!="            { return NE; }
"<="            { return LE; }
">="            { return GE; }
"<"             { return LT; }
">"             { return GT; }
"++"            { return INC; }
"--"            { return DEC; }

";"             { return ';'; }
","             { return ','; }
"("             { return '('; }
")"             { return ')'; }
"{"             { return '{'; }
"}"             { return '}'; }
"["             { return '['; }
"]"             { return ']'; }
"="             { return '='; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"%"             { return '%'; }
"!"             { return '!'; }

[ \t\n]+        ; /* skip whitespace */
.               { /* ignore other characters */ }
%%

int yywrap(void) {
    return 1;
}