# CS401P Compiler (Course Project)

This repository contains a small compiler project created for the CS401P course. The project includes a lexer, a parser that builds an AST for expressions and variable declarations, test cases, and some OS-related files used by the course.

### Contributions
- Sonith: Wrote the grammar rules for parser to build the AST for expressions and variable declarations.
- Sasaank: Defined the C structs for the AST nodes that Sonith's parser will create and wrote the lexer which provides tokens to parser.
- Pavan: Wrote testcases containing mathematical expressions and verified the AST structure is correct for those cases.

## Module 2 

Planned scope for Module 2: continue implementing and testing the lexer + parser pipeline and add a comprehensive test-suite of input programs.

Current lines-of-code for key modules (from local file counts):

- `parser.y` (parser/grammar): 257 lines
- `lexer.l` (lexer): 65 lines
- `TC/` (testcases, all files in the folder): 128 lines (sum of current test files)

### Module 2 — current author attribution

- `parser.y` total: 257 lines
	- Sasaank: 104 lines
	- Sonith: 153 lines (remaining lines in `parser.y`)

- `lexer.l` total: 65 lines
	- Sasaank: entire `lexer.l` (65 lines)

- `TC/` : 128 lines total — testcases committed by Pavan


