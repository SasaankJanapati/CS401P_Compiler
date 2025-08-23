%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

extern char* yytext; // The matched text
%}

%%

[ \t\n]+              /* Ignore whitespace */
"int"		      { yylval.string = strdup(yytext); return INT; }
"float"		      { yylval.string = strdup(yytext); return FLOAT; }
"char"		      { yylval.string = strdup(yytext); return CHAR; }
"if"		      { yylval.string = strdup(yytext); return IF; }
"else"		      { yylval.string = strdup(yytext); return ELSE; }
"true"		      { yylval.string = strdup(yytext); return T; }
"false"		      { yylval.string = strdup(yytext); return F; }
"while"		      { yylval.string = strdup(yytext); return WHILE; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.string = strdup(yytext); return IDEN; }
[0-9]+(\.[0-9]+)?     { yylval.string = strdup(yytext); return NUM; }
"++"                   { yylval.string = strdup(yytext); return INC; }
"--"                   { yylval.string = strdup(yytext); return DEC; }
"+="                   { yylval.string = strdup(yytext); return PEQ; }
"-="                   { yylval.string = strdup(yytext); return MEQ; }
"*="                   { yylval.string = strdup(yytext); return SEQ; }
"/="                   { yylval.string = strdup(yytext); return DEQ; }
">="		      { yylval.string = strdup(yytext); return GTE; }
"<="		      { yylval.string = strdup(yytext); return LTE; }
"!="		      { yylval.string = strdup(yytext); return NE; }
"!"		          { yylval.string = strdup(yytext); return NN; }
"=="		      { yylval.string = strdup(yytext); return EE; }
"&&"		      { yylval.string = strdup(yytext); return AND; }
"||"		      { yylval.string = strdup(yytext); return OR; }
">"                   { yylval.string = strdup(yytext); return GT; }
"<"                   { yylval.string = strdup(yytext); return LT; }
"+"                   { yylval.string = strdup(yytext); return PL; }
"-"                   { yylval.string = strdup(yytext); return MI; }
"*"                   { yylval.string = strdup(yytext); return ST; }
"/"                   { yylval.string = strdup(yytext); return DV; }
"%"                   { yylval.string = strdup(yytext); return MD; }
"="                   { yylval.string = strdup(yytext); return EQ; }
";"                   { yylval.string = strdup(yytext); return SC; }
"("                   { yylval.string = strdup(yytext); return LP; }
")"                   { yylval.string = strdup(yytext); return RP; }
"{"                   { yylval.string = strdup(yytext); return LB; }
"}"                   { yylval.string = strdup(yytext); return RB; }
"["                   { yylval.string = strdup(yytext); return LS; }
"]"                   { yylval.string = strdup(yytext); return RS; }
","                   { yylval.string = strdup(yytext); return CM; }
.                     { yylval.string = strdup(yytext); return yytext[0]; }
%%

int yywrap() {
    return 1;
}

