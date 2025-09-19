# CS401P Compiler (Course Project)

This repository contains a small compiler project created for the CS401P course. The project includes a lexer, a parser that builds an AST for expressions and variable declarations, test cases, and some OS-related files used by the course.

### Contributions
- Sasaank: In charge of the Lexer, Symbol Table, and generating the Three-Address Code (TAC).
- Sonith: In charge of the Parser, the final Stack Code generation, and setting up the project.
- Pavan: In charge of writing all the .xyz test programs and verifying the output at every step.

## Module 4 (Sept 19)

Planned scope for Module 4: add grammar support for OOP concepts such as class declaration, generate stack based instructions for VM till function calls and basic OOP constructs.

Current lines-of-code for key modules (from local file counts):

- `parser.y` (parser/grammar): 1221 lines
- `lexer.l` (lexer): 90 lines
- `TC/` (testcases, all files in the folder): ~200 lines (sum of current test files)

### Module 4 — current author attribution

- `parser.y` total: 1221 lines
	- Sasaank: 582 lines (+203)
	- Sonith: 310 lines (+175)
	- Pavan: 329 lines

- `lexer.l` total: 90 lines
	- Pavan: (+15 lines)

- `TC/` : ~200 lines total (+1 new testcase) — committed by Pavan

## Module 3 (Sept 06)

Planned scope for Module 3: add strict type checking, scope management and parser actions and add a comprehensive test-suite of input programs.

Current lines-of-code for key modules (from local file counts):

- `parser.y` (parser/grammar): 635 lines
- `lexer.l` (lexer): 75 lines
- `TC/` (testcases, all files in the folder): ~195 lines (sum of current test files)

### Module 3 — current author attribution

- `parser.y` total: 635 lines
	- Sasaank: 307 lines (+203)
	- Sonith: 328 lines (+175)

- `lexer.l` total: 75 lines
	- Pavan: (+10 lines)

- `TC/` : 195 lines total (+3 testcases) — committed by Pavan


## Module 2 (Aug 25)

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


