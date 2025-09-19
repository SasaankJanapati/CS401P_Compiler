%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>
extern YYSTYPE yylval;
extern int yylineno;
%}

%x COMMENT

%%
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"return"        { return RETURN; }
"break"         { return BREAK; }
"continue"      { return CONTINUE; }
"do"            { return DO; }

"class"         { return CLASS; }
"public"        { return PUBLIC; }
"private"       { return PRIVATE; }
"protected"     { return PROTECTED; }
"abstract"      { return ABSTRACT; }


"int"           { yylval.str_val = strdup(yytext); return INT; }
"float"         { yylval.str_val = strdup(yytext); return FLOAT; }
"char"          { yylval.str_val = strdup(yytext); return CHAR; }
"void"          { yylval.str_val = strdup(yytext); return VOID; }
"string"        { yylval.str_val = strdup(yytext); return STRING; }

"true"          { yylval.str_val = "1"; return TR; }
"false"         { yylval.str_val = "0"; return FL; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str_val = strdup(yytext); return IDEN; }
[0-9]+\.[0-9]+  { yylval.str_val = strdup(yytext); return NUM; }
[0-9]+          { yylval.str_val = strdup(yytext); return NUM; }
\"[^\"]*\"      { yylval.str_val = strdup(yytext); return STR; }
'.'             { yylval.str_val = strdup(yytext); return CHR; }

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
"?"             { return '?'; }
":"             { return ':'; }
"~"             { return '~'; } /* Destructor token */

[ \t]+        ; /* skip whitespace */
"//".*        ; /* skip single line comments */
"/*"            { BEGIN(COMMENT); }
<COMMENT>"*/"   { BEGIN(INITIAL); }
<COMMENT>\n     { yylineno++; }
<COMMENT>.      ; /* skip all characters in comment */
\n              { yylineno++; }
.               { /* ignore other characters */ }
%%

int yywrap(void) {
    return 1;
}
