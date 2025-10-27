.class_metadata
class_count 2
class_begin Termios -1
field_count 1
field clflag I 0
method_count 2
method Termios Termios.Termios
method copyFrom Termios.copyFrom@Termios
class_end
class_begin TerminalHandler -1
field_count 1
field Eorigtermios Termios 0
method_count 4
method disableRawMode TerminalHandler.disableRawMode
method enableRawMode TerminalHandler.enableRawMode
method tcgetattr TerminalHandler.tcgetattr@I@Termios
method tcsetattr TerminalHandler.tcsetattr@I@I@Termios
class_end
.end_metadata

.code

.method Termios.Termios
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; 'this' for assignment to member 'clflag'
PUSH 0
PUTFIELD 0
RET
.endmethod

.method Termios.copyFrom@Termios
.limit stack 4
.limit locals 2
LOAD_ARG 0 ; 'this' for assignment to member 'clflag'
LOAD_ARG 1  ; Load parameter 'src'
GETFIELD 0 ; Get field 'clflag'
PUTFIELD 0
.endmethod

.method TerminalHandler.disableRawMode
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' for method call
PUSH 0
PUSH 2
LOAD 0 ; Load 'this' to access member object 'Eorigtermios'
GETFIELD 0
INVOKEVIRTUAL 3 ; Call TerminalHandler.tcsetattr@I@I@Termios
.endmethod

.method TerminalHandler.enableRawMode
.limit stack 4
.limit locals 2
LOAD_ARG 0 ; Load 'this' for method call
PUSH 0
LOAD 0 ; Load 'this' to access member object 'Eorigtermios'
GETFIELD 0
INVOKEVIRTUAL 2 ; Call TerminalHandler.tcgetattr@I@Termios
PUSH 1
PUSH STR_0  ; Push address of string literal "Raw mode enabled.\n"
PUSH 18
POP
LOAD 1  ; Load local var raw
LOAD 0 ; Load 'this' to access member object 'Eorigtermios'
GETFIELD 0
INVOKEVIRTUAL 1 ; Call Termios.copyFrom@Termios
LOAD 1  ; Load local var raw
LOAD 1  ; Load local var raw
GETFIELD 0 ; Get field 'clflag'
PUSH 4
IDIV
PUSH 4
IMUL
PUTFIELD 0 ; Set field 'clflag'
LOAD_ARG 0 ; Load 'this' for method call
PUSH 0
PUSH 2
LOAD 1  ; Load local var raw
INVOKEVIRTUAL 3 ; Call TerminalHandler.tcsetattr@I@I@Termios
.endmethod

.method TerminalHandler.tcgetattr@I@Termios
.limit stack 4
.limit locals 3
LOAD_ARG 2  ; Load parameter 't'
PUSH 1
PUTFIELD 0 ; Set field 'clflag'
.endmethod

.method TerminalHandler.tcsetattr@I@I@Termios
.limit stack 4
.limit locals 4
PUSH 1
PUSH STR_1  ; Push address of string literal "Termios attributes set.\n"
PUSH 25
POP
.endmethod

.data
STR_0: .word "Raw mode enabled.\n"
STR_1: .word "Termios attributes set.\n"
