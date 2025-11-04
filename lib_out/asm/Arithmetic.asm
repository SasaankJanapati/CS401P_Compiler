.class_metadata
class_count 1
class_begin Arithmetic None
field_count 0
method_count 16
method abs Arithmetic.abs@I
method abs Arithmetic.abs@F
method abs Arithmetic.abs@F
method sqrt Arithmetic.sqrt@F
method sqrt Arithmetic.sqrt@F
method exp Arithmetic.exp@F
method exp Arithmetic.exp@F
method power Arithmetic.power@F@I
method power Arithmetic.power@F@I
method max Arithmetic.max@I@I
method max Arithmetic.max@F@F
method max Arithmetic.max@F@F
method min Arithmetic.min@I@I
method min Arithmetic.min@F@F
method min Arithmetic.min@F@F
method Arithmetic Arithmetic.Arithmetic
class_end
.end_metadata

.code

.method Arithmetic.abs@I
.limit stack 4
.limit locals 1
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 0
LOAD 0  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L0
JMP L1
L0:
LOAD 0  ; Load parameter 'x'
INEG
RET
L1:
LOAD 0  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.abs@F
.limit stack 4
.limit locals 2
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 1
LOAD 1  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L2
JMP L3
L2:
LOAD 1  ; Load parameter 'x'
FNEG
RET
L3:
LOAD 1  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.abs@F
.limit stack 4
.limit locals 3
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 2
LOAD 2  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L4
JMP L5
L4:
LOAD 2  ; Load parameter 'x'
FNEG
RET
L5:
LOAD 2  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.sqrt@F
.limit stack 4
.limit locals 7
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 3
LOAD 3  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L6
JMP L7
L6:
PUSH 1
INEG
RET
L7:
LOAD 3  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L8
JMP L10
L10:
LOAD 3  ; Load parameter 'x'
PUSH 1
ICMP_EQ
JNZ L8
JMP L9
L8:
LOAD 3  ; Load parameter 'x'
RET
L9:
LOAD 3  ; Load parameter 'x'
STORE 4 ; Init guess
FPUSH 0.0000000001
STORE 5 ; Init eps
L11:
JMP L12
L12:
FPUSH 0.5
LOAD 4  ; Load local var guess
LOAD 3  ; Load parameter 'x'
LOAD 4  ; Load local var guess
FDIV
FADD
FMUL
STORE 6 ; Init newGuess
LOAD_ARG 0 ; Load 'this' for method call
LOAD 6  ; Load local var newGuess
LOAD 4  ; Load local var guess
FSUB
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 ; Call Arithmetic.abs@F
LOAD 5  ; Load local var eps
ICMP_LT
JNZ L14
JMP L15
L14:
JMP L13 ; BREAK
L15:
LOAD 6  ; Load local var newGuess
STORE 4 ; Store to local 'guess'
JMP L11
L13:
LOAD 4  ; Load local var guess
RET
.endmethod

.method Arithmetic.sqrt@F
.limit stack 4
.limit locals 11
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 7
LOAD 7  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L16
JMP L17
L16:
PUSH 1
INEG
RET
L17:
LOAD 7  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L18
JMP L20
L20:
LOAD 7  ; Load parameter 'x'
PUSH 1
ICMP_EQ
JNZ L18
JMP L19
L18:
LOAD 7  ; Load parameter 'x'
RET
L19:
LOAD 7  ; Load parameter 'x'
STORE 8 ; Init guess
FPUSH 0.0000000001
STORE 9 ; Init eps
L21:
JMP L22
L22:
FPUSH 0.5
LOAD 8  ; Load local var guess
LOAD 7  ; Load parameter 'x'
LOAD 8  ; Load local var guess
FDIV
FADD
FMUL
STORE 10 ; Init newGuess
LOAD_ARG 0 ; Load 'this' for method call
LOAD 10  ; Load local var newGuess
LOAD 8  ; Load local var guess
FSUB
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 ; Call Arithmetic.abs@F
LOAD 9  ; Load local var eps
ICMP_LT
JNZ L24
JMP L25
L24:
JMP L23 ; BREAK
L25:
LOAD 10  ; Load local var newGuess
STORE 8 ; Store to local 'guess'
JMP L21
L23:
LOAD 8  ; Load local var guess
RET
.endmethod

.method Arithmetic.exp@F
.limit stack 4
.limit locals 16
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 11
PUSH 1
STORE 12 ; Init term
PUSH 1
STORE 13 ; Init sum
PUSH 1
STORE 14 ; Init n
FPUSH 0.0000000000001
STORE 15 ; Init eps
L26:
LOAD_ARG 0 ; Load 'this' for method call
LOAD 12  ; Load local var term
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 ; Call Arithmetic.abs@F
LOAD 15  ; Load local var eps
ICMP_GT
JNZ L27
JMP L28
L27:
LOAD 12  ; Load local var term
LOAD 11  ; Load parameter 'x'
FMUL
LOAD 14  ; Load local var n
FDIV
STORE 12 ; Store to local 'term'
LOAD 13  ; Load local var sum
LOAD 12  ; Load local var term
FADD
STORE 13 ; Store to local 'sum'
LOAD 14  ; Load local var n
PUSH 1
IADD
STORE 14 ; Store to local 'n'
JMP L26
L28:
LOAD 13  ; Load local var sum
RET
.endmethod

.method Arithmetic.exp@F
.limit stack 4
.limit locals 21
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 16
PUSH 1
STORE 17 ; Init term
PUSH 1
STORE 18 ; Init sum
PUSH 1
STORE 19 ; Init n
FPUSH 0.0000000000001
STORE 20 ; Init eps
L29:
LOAD_ARG 0 ; Load 'this' for method call
LOAD 17  ; Load local var term
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 ; Call Arithmetic.abs@F
LOAD 20  ; Load local var eps
ICMP_GT
JNZ L30
JMP L31
L30:
LOAD 16  ; Load parameter 'x'
LOAD 19  ; Load local var n
FDIV
STORE 17 ; Store to local 'term'
LOAD 17  ; Load local var term
STORE 18 ; Store to local 'sum'
LOAD 19 ; Load local 'n'
DUP
PUSH 1
IADD ; ++
STORE 19 ; Store local 'n'
POP
JMP L29
L31:
LOAD 18  ; Load local var sum
RET
.endmethod

.method Arithmetic.power@F@I
.limit stack 4
.limit locals 24
LOAD_ARG 0 ; Copy arg 'base' to local
STORE 21
LOAD_ARG 1 ; Copy arg 'exponent' to local
STORE 22
LOAD 22  ; Load parameter 'exponent'
PUSH 0
ICMP_EQ
JNZ L32
JMP L33
L32:
PUSH 1
RET
L33:
LOAD 22  ; Load parameter 'exponent'
PUSH 0
ICMP_LT
JNZ L34
JMP L35
L34:
PUSH 1
LOAD_ARG 0 ; Load 'this' for method call
LOAD 21  ; Load parameter 'base'
LOAD 22  ; Load parameter 'exponent'
INEG
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 7 ; Call Arithmetic.power@F@I
RET
L35:
PUSH 1
STORE 23 ; Init result
L36:
LOAD 22  ; Load parameter 'exponent'
PUSH 0
ICMP_GT
JNZ L37
JMP L38
L37:
LOAD 22  ; Load parameter 'exponent'
PUSH 2
IMOD
PUSH 1
ICMP_EQ
JNZ L39
JMP L40
L39:
LOAD 23  ; Load local var result
LOAD 21  ; Load parameter 'base'
FMUL
STORE 23 ; Store to local 'result'
L40:
LOAD 21  ; Load parameter 'base'
LOAD 21  ; Load parameter 'base'
FMUL
STORE 21 ; Store to local 'base'
LOAD 22  ; Load parameter 'exponent'
PUSH 2
IDIV
STORE 22 ; Store to local 'exponent'
JMP L36
L38:
LOAD 23  ; Load local var result
RET
.endmethod

.method Arithmetic.power@F@I
.limit stack 4
.limit locals 27
LOAD_ARG 0 ; Copy arg 'base' to local
STORE 24
LOAD_ARG 1 ; Copy arg 'exp' to local
STORE 25
LOAD 25  ; Load parameter 'exp'
PUSH 0
ICMP_EQ
JNZ L41
JMP L42
L41:
PUSH 1
RET
L42:
LOAD 25  ; Load parameter 'exp'
PUSH 0
ICMP_LT
JNZ L43
JMP L44
L43:
FPUSH 1.0
LOAD_ARG 0 ; Load 'this' for method call
LOAD 24  ; Load parameter 'base'
LOAD 25  ; Load parameter 'exp'
INEG
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 7 ; Call Arithmetic.power@F@I
FDIV
RET
L44:
PUSH 1
STORE 26 ; Init result
L45:
LOAD 25  ; Load parameter 'exp'
PUSH 0
ICMP_GT
JNZ L46
JMP L47
L46:
LOAD 25  ; Load parameter 'exp'
PUSH 2
IMOD
PUSH 1
ICMP_EQ
JNZ L48
JMP L49
L48:
LOAD 24  ; Load parameter 'base'
STORE 26 ; Store to local 'result'
L49:
LOAD 24  ; Load parameter 'base'
STORE 24 ; Store to local 'base'
PUSH 2
STORE 25 ; Store to local 'exp'
JMP L45
L47:
LOAD 26  ; Load local var result
RET
.endmethod

.method Arithmetic.max@I@I
.limit stack 4
.limit locals 29
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 27
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 28
LOAD 27  ; Load parameter 'a'
LOAD 28  ; Load parameter 'b'
ICMP_GT
JNZ L50
JMP L51
L50:
LOAD 27  ; Load parameter 'a'
RET
L51:
LOAD 28  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.max@F@F
.limit stack 4
.limit locals 31
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 29
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 30
LOAD 29  ; Load parameter 'a'
LOAD 30  ; Load parameter 'b'
FCMP_GT
JNZ L52
JMP L53
L52:
LOAD 29  ; Load parameter 'a'
RET
L53:
LOAD 30  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.max@F@F
.limit stack 4
.limit locals 33
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 31
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 32
LOAD 31  ; Load parameter 'a'
LOAD 32  ; Load parameter 'b'
FCMP_GT
JNZ L54
JMP L55
L54:
LOAD 31  ; Load parameter 'a'
RET
L55:
LOAD 32  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@I@I
.limit stack 4
.limit locals 35
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 33
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 34
LOAD 33  ; Load parameter 'a'
LOAD 34  ; Load parameter 'b'
ICMP_LT
JNZ L56
JMP L57
L56:
LOAD 33  ; Load parameter 'a'
RET
L57:
LOAD 34  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@F@F
.limit stack 4
.limit locals 37
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 35
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 36
LOAD 35  ; Load parameter 'a'
LOAD 36  ; Load parameter 'b'
FCMP_LT
JNZ L58
JMP L59
L58:
LOAD 35  ; Load parameter 'a'
RET
L59:
LOAD 36  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@F@F
.limit stack 4
.limit locals 39
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 37
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 38
LOAD 37  ; Load parameter 'a'
LOAD 38  ; Load parameter 'b'
FCMP_GT
JNZ L60
JMP L61
L60:
LOAD 37  ; Load parameter 'a'
RET
L61:
LOAD 38  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.Arithmetic
.limit stack 10
.limit locals 1
RET
.endmethod
