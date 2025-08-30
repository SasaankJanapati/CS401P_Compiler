parser: y.tab.c lex.yy.c y.tab.h
	gcc -w -g y.tab.c lex.yy.c -ll -o parser
y.tab.c: parser.y
	yacc --debug -v -d -t --verbose parser.y
lex.yy.c: lexer.l
	lex lexer.l
clean: 
	rm -f parser y.tab.c y.tab.h lex.yy.c y.output
