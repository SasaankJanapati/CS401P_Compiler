.class_metadata
class_count 2
class_begin Termios None
field_count 1
field clflag I 0
method_count 2
method Termios Termios.Termios
method copyFrom Termios.copyFrom@Termios
class_end
class_begin TerminalHandler None
field_count 1
field Eorigtermios Termios 3
method_count 5
method disableRawMode TerminalHandler.disableRawMode
method enableRawMode TerminalHandler.enableRawMode
method tcgetattr TerminalHandler.tcgetattr@I@Termios
method tcsetattr TerminalHandler.tcsetattr@I@I@Termios
method TerminalHandler TerminalHandler.TerminalHandler
class_end
.end_metadata

.code

.method Termios.Termios
.limit stack 10
.limit locals 2
LOAD_ARG 0      ; Push 'this' reference for field 'clflag'
PUSH 0      ; Default value for 'clflag'
PUTFIELD 0 ; Store 0 to 'clflag'
LOAD_ARG 0 ; 'this' for assignment to member 'clflag'
PUSH 0
PUTFIELD 0
RET
.endmethod

.method Termios.copyFrom@Termios
.limit stack 4
.limit locals 181
LOAD_ARG 1 ; Copy arg 'src' to local
STORE 180
LOAD_ARG 0 ; 'this' for assignment to member 'clflag'
LOAD 180  ; Load parameter 'src'
GETFIELD 0 ; Get field 'clflag'
PUTFIELD 0
RET
.endmethod

.method TerminalHandler.disableRawMode
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member object 'Eorigtermios'
GETFIELD 0
PUSH 2
PUSH 0
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 3 4; Call TerminalHandler.tcsetattr@I@I@Termios
POP ; discard fp
RET
.endmethod

.method TerminalHandler.enableRawMode
.limit stack 4
.limit locals 182
LOAD_ARG 0 ; Load 'this' to access member object 'Eorigtermios'
GETFIELD 0
PUSH 0
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 2 3; Call TerminalHandler.tcgetattr@I@Termios
POP ; discard fp
PUSH 20 ; String literal length
NEWARRAY C ; Create char array for string "Raw mode enabled.\n"
DUP ; Duplicate array ref for ASTORE
PUSH 0 ; Push index 0
PUSH 82 ; Push char 'R'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 1 ; Push index 1
PUSH 97 ; Push char 'a'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 2 ; Push index 2
PUSH 119 ; Push char 'w'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 3 ; Push index 3
PUSH 32 ; Push char ' '
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 4 ; Push index 4
PUSH 109 ; Push char 'm'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 5 ; Push index 5
PUSH 111 ; Push char 'o'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 6 ; Push index 6
PUSH 100 ; Push char 'd'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 7 ; Push index 7
PUSH 101 ; Push char 'e'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 8 ; Push index 8
PUSH 32 ; Push char ' '
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 9 ; Push index 9
PUSH 101 ; Push char 'e'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 10 ; Push index 10
PUSH 110 ; Push char 'n'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 11 ; Push index 11
PUSH 97 ; Push char 'a'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 12 ; Push index 12
PUSH 98 ; Push char 'b'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 13 ; Push index 13
PUSH 108 ; Push char 'l'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 14 ; Push index 14
PUSH 101 ; Push char 'e'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 15 ; Push index 15
PUSH 100 ; Push char 'd'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 16 ; Push index 16
PUSH 46 ; Push char '.'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 17 ; Push index 17
PUSH 10 ; Push escaped char '\n'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 19 ; Push index 19 for null terminator
PUSH 0 ; Push null terminator
ASTORE ; Store null terminator in array
PUSH 18
PUSH 1
SYS_CALL WRITE ; write
POP
LOAD_ARG 0 ; Load 'this' to access member object 'Eorigtermios'
GETFIELD 0
LOAD 181  ; Load local var raw
LOAD 181  ; Load local var raw
INVOKEVIRTUAL 1 2; Call Termios.copyFrom@Termios
POP ; discard fp
LOAD 181  ; Load local var raw
LOAD 181  ; Load local var raw
GETFIELD 0 ; Get field 'clflag'
PUSH 4
IDIV
PUSH 4
IMUL
PUTFIELD 0 ; Set field 'clflag'
LOAD 181  ; Load local var raw
PUSH 2
PUSH 0
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 3 4; Call TerminalHandler.tcsetattr@I@I@Termios
POP ; discard fp
RET
.endmethod

.method TerminalHandler.tcgetattr@I@Termios
.limit stack 4
.limit locals 184
LOAD_ARG 1 ; Copy arg 'fd' to local
STORE 182
LOAD_ARG 2 ; Copy arg 't' to local
STORE 183
LOAD 183  ; Load parameter 't'
PUSH 1
PUTFIELD 0 ; Set field 'clflag'
RET
.endmethod

.method TerminalHandler.tcsetattr@I@I@Termios
.limit stack 4
.limit locals 187
LOAD_ARG 1 ; Copy arg 'fd' to local
STORE 184
LOAD_ARG 2 ; Copy arg 'flag' to local
STORE 185
LOAD_ARG 3 ; Copy arg 't' to local
STORE 186
PUSH 26 ; String literal length
NEWARRAY C ; Create char array for string "Termios attributes set.\n"
DUP ; Duplicate array ref for ASTORE
PUSH 0 ; Push index 0
PUSH 84 ; Push char 'T'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 1 ; Push index 1
PUSH 101 ; Push char 'e'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 2 ; Push index 2
PUSH 114 ; Push char 'r'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 3 ; Push index 3
PUSH 109 ; Push char 'm'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 4 ; Push index 4
PUSH 105 ; Push char 'i'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 5 ; Push index 5
PUSH 111 ; Push char 'o'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 6 ; Push index 6
PUSH 115 ; Push char 's'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 7 ; Push index 7
PUSH 32 ; Push char ' '
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 8 ; Push index 8
PUSH 97 ; Push char 'a'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 9 ; Push index 9
PUSH 116 ; Push char 't'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 10 ; Push index 10
PUSH 116 ; Push char 't'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 11 ; Push index 11
PUSH 114 ; Push char 'r'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 12 ; Push index 12
PUSH 105 ; Push char 'i'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 13 ; Push index 13
PUSH 98 ; Push char 'b'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 14 ; Push index 14
PUSH 117 ; Push char 'u'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 15 ; Push index 15
PUSH 116 ; Push char 't'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 16 ; Push index 16
PUSH 101 ; Push char 'e'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 17 ; Push index 17
PUSH 115 ; Push char 's'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 18 ; Push index 18
PUSH 32 ; Push char ' '
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 19 ; Push index 19
PUSH 115 ; Push char 's'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 20 ; Push index 20
PUSH 101 ; Push char 'e'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 21 ; Push index 21
PUSH 116 ; Push char 't'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 22 ; Push index 22
PUSH 46 ; Push char '.'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 23 ; Push index 23
PUSH 10 ; Push escaped char '\n'
ASTORE ; Store char in array
DUP ; Duplicate array ref for ASTORE
PUSH 25 ; Push index 25 for null terminator
PUSH 0 ; Push null terminator
ASTORE ; Store null terminator in array
PUSH 25
PUSH 1
SYS_CALL WRITE ; write
POP
RET
.endmethod

.method TerminalHandler.TerminalHandler
.limit stack 10
.limit locals 2
LOAD_ARG 0      ; Push 'this' reference for field 'Eorigtermios'
NEW Termios
DUP
INVOKEVIRTUAL 0 0; Call default ctor for Termios
POP ; discard fp
PUTFIELD 0 ; Store new instance to 'Eorigtermios'
RET
.endmethod
