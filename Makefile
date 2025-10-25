parser: y.tab.c lex.yy.c y.tab.h
	gcc -w -g y.tab.c lex.yy.c -ll -o parser
y.tab.c: parser.y
	yacc --debug -v -d -t --verbose parser.y
lex.yy.c: lexer.l
	lex lexer.l
clean: 
	rm -f parser y.tab.c y.tab.h lex.yy.c y.output  error.log
grammar: Grammar.y
	lex lexer.l
	yacc --debug -v -d -t --verbose Grammar.y
	gcc -w -g y.tab.c lex.yy.c -ll -o grammar
clean_grammar: 
	rm -f grammar y.tab.c y.tab.h lex.yy.c y.output
	
