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
.limit locals 135
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 134
LOAD 134  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L0
JMP L1
L0:
LOAD 134  ; Load parameter 'x'
INEG
RET
L1:
LOAD 134  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.abs@F
.limit stack 4
.limit locals 136
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 135
LOAD 135  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L2
JMP L3
L2:
LOAD 135  ; Load parameter 'x'
FNEG
RET
L3:
LOAD 135  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.abs@F
.limit stack 4
.limit locals 137
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 136
LOAD 136  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L4
JMP L5
L4:
LOAD 136  ; Load parameter 'x'
FNEG
RET
L5:
LOAD 136  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.sqrt@F
.limit stack 4
.limit locals 141
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 137
LOAD 137  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L6
JMP L7
L6:
PUSH 1
INEG
RET
L7:
LOAD 137  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L8
JMP L10
L10:
LOAD 137  ; Load parameter 'x'
PUSH 1
ICMP_EQ
JNZ L8
JMP L9
L8:
LOAD 137  ; Load parameter 'x'
RET
L9:
LOAD 137  ; Load parameter 'x'
STORE 138 ; Init guess
FPUSH 0.0000000001
STORE 139 ; Init eps
L11:
JMP L12
L12:
FPUSH 0.5
LOAD 138  ; Load local var guess
LOAD 137  ; Load parameter 'x'
LOAD 138  ; Load local var guess
FDIV
FADD
FMUL
STORE 140 ; Init newGuess
LOAD_ARG 0 ; Load 'this' for method call
LOAD 140  ; Load local var newGuess
LOAD 138  ; Load local var guess
FSUB
INVOKEVIRTUAL 1 1; Call Arithmetic.abs@F
LOAD 139  ; Load local var eps
ICMP_LT
JNZ L14
JMP L15
L14:
JMP L13 ; BREAK
L15:
LOAD 140  ; Load local var newGuess
STORE 138 ; Store to local 'guess'
JMP L11
L13:
LOAD 138  ; Load local var guess
RET
.endmethod

.method Arithmetic.sqrt@F
.limit stack 4
.limit locals 145
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 141
LOAD 141  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L16
JMP L17
L16:
PUSH 1
INEG
RET
L17:
LOAD 141  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L18
JMP L20
L20:
LOAD 141  ; Load parameter 'x'
PUSH 1
ICMP_EQ
JNZ L18
JMP L19
L18:
LOAD 141  ; Load parameter 'x'
RET
L19:
LOAD 141  ; Load parameter 'x'
STORE 142 ; Init guess
FPUSH 0.0000000001
STORE 143 ; Init eps
L21:
JMP L22
L22:
FPUSH 0.5
LOAD 142  ; Load local var guess
LOAD 141  ; Load parameter 'x'
LOAD 142  ; Load local var guess
FDIV
FADD
FMUL
STORE 144 ; Init newGuess
LOAD_ARG 0 ; Load 'this' for method call
LOAD 144  ; Load local var newGuess
LOAD 142  ; Load local var guess
FSUB
INVOKEVIRTUAL 1 1; Call Arithmetic.abs@F
LOAD 143  ; Load local var eps
ICMP_LT
JNZ L24
JMP L25
L24:
JMP L23 ; BREAK
L25:
LOAD 144  ; Load local var newGuess
STORE 142 ; Store to local 'guess'
JMP L21
L23:
LOAD 142  ; Load local var guess
RET
.endmethod

.method Arithmetic.exp@F
.limit stack 4
.limit locals 150
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 145
PUSH 1
STORE 146 ; Init term
PUSH 1
STORE 147 ; Init sum
PUSH 1
STORE 148 ; Init n
FPUSH 0.0000000000001
STORE 149 ; Init eps
L26:
LOAD_ARG 0 ; Load 'this' for method call
LOAD 146  ; Load local var term
INVOKEVIRTUAL 1 1; Call Arithmetic.abs@F
LOAD 149  ; Load local var eps
ICMP_GT
JNZ L27
JMP L28
L27:
LOAD 146  ; Load local var term
LOAD 145  ; Load parameter 'x'
FMUL
LOAD 148  ; Load local var n
FDIV
STORE 146 ; Store to local 'term'
LOAD 147  ; Load local var sum
LOAD 146  ; Load local var term
FADD
STORE 147 ; Store to local 'sum'
LOAD 148  ; Load local var n
PUSH 1
IADD
STORE 148 ; Store to local 'n'
JMP L26
L28:
LOAD 147  ; Load local var sum
RET
.endmethod

.method Arithmetic.exp@F
.limit stack 4
.limit locals 155
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 150
PUSH 1
STORE 151 ; Init term
PUSH 1
STORE 152 ; Init sum
PUSH 1
STORE 153 ; Init n
FPUSH 0.0000000000001
STORE 154 ; Init eps
L29:
LOAD_ARG 0 ; Load 'this' for method call
LOAD 151  ; Load local var term
INVOKEVIRTUAL 1 1; Call Arithmetic.abs@F
LOAD 154  ; Load local var eps
ICMP_GT
JNZ L30
JMP L31
L30:
LOAD 150  ; Load parameter 'x'
LOAD 153  ; Load local var n
FDIV
STORE 151 ; Store to local 'term'
LOAD 151  ; Load local var term
STORE 152 ; Store to local 'sum'
LOAD 153 ; Load local 'n'
DUP
PUSH 1
IADD ; ++
STORE 153 ; Store local 'n'
POP
JMP L29
L31:
LOAD 152  ; Load local var sum
RET
.endmethod

.method Arithmetic.power@F@I
.limit stack 4
.limit locals 158
LOAD_ARG 0 ; Copy arg 'base' to local
STORE 155
LOAD_ARG 1 ; Copy arg 'exponent' to local
STORE 156
LOAD 156  ; Load parameter 'exponent'
PUSH 0
ICMP_EQ
JNZ L32
JMP L33
L32:
PUSH 1
RET
L33:
LOAD 156  ; Load parameter 'exponent'
PUSH 0
ICMP_LT
JNZ L34
JMP L35
L34:
PUSH 1
LOAD_ARG 0 ; Load 'this' for method call
LOAD 156  ; Load parameter 'exponent'
INEG
LOAD 155  ; Load parameter 'base'
INVOKEVIRTUAL 7 2; Call Arithmetic.power@F@I
RET
L35:
PUSH 1
STORE 157 ; Init result
L36:
LOAD 156  ; Load parameter 'exponent'
PUSH 0
ICMP_GT
JNZ L37
JMP L38
L37:
LOAD 156  ; Load parameter 'exponent'
PUSH 2
IMOD
PUSH 1
ICMP_EQ
JNZ L39
JMP L40
L39:
LOAD 157  ; Load local var result
LOAD 155  ; Load parameter 'base'
FMUL
STORE 157 ; Store to local 'result'
L40:
LOAD 155  ; Load parameter 'base'
LOAD 155  ; Load parameter 'base'
FMUL
STORE 155 ; Store to local 'base'
LOAD 156  ; Load parameter 'exponent'
PUSH 2
IDIV
STORE 156 ; Store to local 'exponent'
JMP L36
L38:
LOAD 157  ; Load local var result
RET
.endmethod

.method Arithmetic.power@F@I
.limit stack 4
.limit locals 161
LOAD_ARG 0 ; Copy arg 'base' to local
STORE 158
LOAD_ARG 1 ; Copy arg 'exp' to local
STORE 159
LOAD 159  ; Load parameter 'exp'
PUSH 0
ICMP_EQ
JNZ L41
JMP L42
L41:
PUSH 1
RET
L42:
LOAD 159  ; Load parameter 'exp'
PUSH 0
ICMP_LT
JNZ L43
JMP L44
L43:
FPUSH 1.0
LOAD_ARG 0 ; Load 'this' for method call
LOAD 159  ; Load parameter 'exp'
INEG
LOAD 158  ; Load parameter 'base'
INVOKEVIRTUAL 7 2; Call Arithmetic.power@F@I
FDIV
RET
L44:
PUSH 1
STORE 160 ; Init result
L45:
LOAD 159  ; Load parameter 'exp'
PUSH 0
ICMP_GT
JNZ L46
JMP L47
L46:
LOAD 159  ; Load parameter 'exp'
PUSH 2
IMOD
PUSH 1
ICMP_EQ
JNZ L48
JMP L49
L48:
LOAD 158  ; Load parameter 'base'
STORE 160 ; Store to local 'result'
L49:
LOAD 158  ; Load parameter 'base'
STORE 158 ; Store to local 'base'
PUSH 2
STORE 159 ; Store to local 'exp'
JMP L45
L47:
LOAD 160  ; Load local var result
RET
.endmethod

.method Arithmetic.max@I@I
.limit stack 4
.limit locals 163
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 161
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 162
LOAD 161  ; Load parameter 'a'
LOAD 162  ; Load parameter 'b'
ICMP_GT
JNZ L50
JMP L51
L50:
LOAD 161  ; Load parameter 'a'
RET
L51:
LOAD 162  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.max@F@F
.limit stack 4
.limit locals 165
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 163
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 164
LOAD 163  ; Load parameter 'a'
LOAD 164  ; Load parameter 'b'
FCMP_GT
JNZ L52
JMP L53
L52:
LOAD 163  ; Load parameter 'a'
RET
L53:
LOAD 164  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.max@F@F
.limit stack 4
.limit locals 167
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 165
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 166
LOAD 165  ; Load parameter 'a'
LOAD 166  ; Load parameter 'b'
FCMP_GT
JNZ L54
JMP L55
L54:
LOAD 165  ; Load parameter 'a'
RET
L55:
LOAD 166  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@I@I
.limit stack 4
.limit locals 169
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 167
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 168
LOAD 167  ; Load parameter 'a'
LOAD 168  ; Load parameter 'b'
ICMP_LT
JNZ L56
JMP L57
L56:
LOAD 167  ; Load parameter 'a'
RET
L57:
LOAD 168  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@F@F
.limit stack 4
.limit locals 171
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 169
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 170
LOAD 169  ; Load parameter 'a'
LOAD 170  ; Load parameter 'b'
FCMP_LT
JNZ L58
JMP L59
L58:
LOAD 169  ; Load parameter 'a'
RET
L59:
LOAD 170  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@F@F
.limit stack 4
.limit locals 173
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 171
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 172
LOAD 171  ; Load parameter 'a'
LOAD 172  ; Load parameter 'b'
FCMP_GT
JNZ L60
JMP L61
L60:
LOAD 171  ; Load parameter 'a'
RET
L61:
LOAD 172  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.Arithmetic
.limit stack 10
.limit locals 1
RET
.endmethod
