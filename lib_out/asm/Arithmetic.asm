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
.limit locals 181
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 180
LOAD 180  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L0
JMP L1
L0:
LOAD 180  ; Load parameter 'x'
INEG
RET
L1:
LOAD 180  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.abs@F
.limit stack 4
.limit locals 182
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 181
LOAD 181  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L2
JMP L3
L2:
LOAD 181  ; Load parameter 'x'
FNEG
RET
L3:
LOAD 181  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.abs@F
.limit stack 4
.limit locals 183
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 182
LOAD 182  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L4
JMP L5
L4:
LOAD 182  ; Load parameter 'x'
FNEG
RET
L5:
LOAD 182  ; Load parameter 'x'
RET
.endmethod

.method Arithmetic.sqrt@F
.limit stack 4
.limit locals 187
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 183
LOAD 183  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L6
JMP L7
L6:
PUSH 1
INEG
RET
L7:
LOAD 183  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L8
JMP L10
L10:
LOAD 183  ; Load parameter 'x'
PUSH 1
ICMP_EQ
JNZ L8
JMP L9
L8:
LOAD 183  ; Load parameter 'x'
RET
L9:
LOAD 183  ; Load parameter 'x'
STORE 184 ; Init guess
FPUSH 0.0000000001
STORE 185 ; Init eps
L11:
JMP L12
L12:
FPUSH 0.5
LOAD 184  ; Load local var guess
LOAD 183  ; Load parameter 'x'
LOAD 184  ; Load local var guess
FDIV
FADD
FMUL
STORE 186 ; Init newGuess
LOAD 186  ; Load local var newGuess
LOAD 184  ; Load local var guess
FSUB
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 2; Call Arithmetic.abs@F
LOAD 185  ; Load local var eps
ICMP_LT
JNZ L14
JMP L15
L14:
JMP L13 ; BREAK
L15:
LOAD 186  ; Load local var newGuess
STORE 184 ; Store to local 'guess'
JMP L11
L13:
LOAD 184  ; Load local var guess
RET
.endmethod

.method Arithmetic.sqrt@F
.limit stack 4
.limit locals 191
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 187
LOAD 187  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L16
JMP L17
L16:
PUSH 1
INEG
RET
L17:
LOAD 187  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L18
JMP L20
L20:
LOAD 187  ; Load parameter 'x'
PUSH 1
ICMP_EQ
JNZ L18
JMP L19
L18:
LOAD 187  ; Load parameter 'x'
RET
L19:
LOAD 187  ; Load parameter 'x'
STORE 188 ; Init guess
FPUSH 0.0000000001
STORE 189 ; Init eps
L21:
JMP L22
L22:
FPUSH 0.5
LOAD 188  ; Load local var guess
LOAD 187  ; Load parameter 'x'
LOAD 188  ; Load local var guess
FDIV
FADD
FMUL
STORE 190 ; Init newGuess
LOAD 190  ; Load local var newGuess
LOAD 188  ; Load local var guess
FSUB
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 2; Call Arithmetic.abs@F
LOAD 189  ; Load local var eps
ICMP_LT
JNZ L24
JMP L25
L24:
JMP L23 ; BREAK
L25:
LOAD 190  ; Load local var newGuess
STORE 188 ; Store to local 'guess'
JMP L21
L23:
LOAD 188  ; Load local var guess
RET
.endmethod

.method Arithmetic.exp@F
.limit stack 4
.limit locals 196
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 191
PUSH 1
STORE 192 ; Init term
PUSH 1
STORE 193 ; Init sum
PUSH 1
STORE 194 ; Init n
FPUSH 0.0000000000001
STORE 195 ; Init eps
L26:
LOAD 192  ; Load local var term
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 2; Call Arithmetic.abs@F
LOAD 195  ; Load local var eps
ICMP_GT
JNZ L27
JMP L28
L27:
LOAD 192  ; Load local var term
LOAD 191  ; Load parameter 'x'
FMUL
LOAD 194  ; Load local var n
FDIV
STORE 192 ; Store to local 'term'
LOAD 193  ; Load local var sum
LOAD 192  ; Load local var term
FADD
STORE 193 ; Store to local 'sum'
LOAD 194  ; Load local var n
PUSH 1
IADD
STORE 194 ; Store to local 'n'
JMP L26
L28:
LOAD 193  ; Load local var sum
RET
.endmethod

.method Arithmetic.exp@F
.limit stack 4
.limit locals 201
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 196
PUSH 1
STORE 197 ; Init term
PUSH 1
STORE 198 ; Init sum
PUSH 1
STORE 199 ; Init n
FPUSH 0.0000000000001
STORE 200 ; Init eps
L29:
LOAD 197  ; Load local var term
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 2; Call Arithmetic.abs@F
LOAD 200  ; Load local var eps
ICMP_GT
JNZ L30
JMP L31
L30:
LOAD 196  ; Load parameter 'x'
LOAD 199  ; Load local var n
FDIV
STORE 197 ; Store to local 'term'
LOAD 197  ; Load local var term
STORE 198 ; Store to local 'sum'
LOAD 199 ; Load local 'n'
DUP
PUSH 1
IADD ; ++
STORE 199 ; Store local 'n'
POP
JMP L29
L31:
LOAD 198  ; Load local var sum
RET
.endmethod

.method Arithmetic.power@F@I
.limit stack 4
.limit locals 205
LOAD_ARG 1 ; Copy arg 'base' to local
STORE 201
LOAD_ARG 2 ; Copy arg 'exponent' to local
STORE 202
FPUSH 1.0
STORE 203 ; Init result
LOAD 202  ; Load parameter 'exponent'
STORE 204 ; Init exp
LOAD 204  ; Load local var exp
PUSH 0
ICMP_LT
JNZ L32
JMP L33
L32:
LOAD 204  ; Load local var exp
INEG
STORE 204 ; Store to local 'exp'
L33:
L34:
LOAD 204  ; Load local var exp
PUSH 0
ICMP_GT
JNZ L35
JMP L36
L35:
LOAD 204  ; Load local var exp
PUSH 2
IDIV
PUSH 1
ICMP_EQ
JNZ L37
JMP L38
L37:
LOAD 201  ; Load parameter 'base'
STORE 203 ; Store to local 'result'
L38:
LOAD 201  ; Load parameter 'base'
STORE 201 ; Store to local 'base'
LOAD 204  ; Load local var exp
PUSH 2
IDIV
STORE 204 ; Store to local 'exp'
JMP L34
L36:
LOAD 202  ; Load parameter 'exponent'
PUSH 0
ICMP_LT
JNZ L39
JMP L40
L39:
FPUSH 1.0
LOAD 203  ; Load local var result
FDIV
STORE 203 ; Store to local 'result'
L40:
LOAD 203  ; Load local var result
RET
.endmethod

.method Arithmetic.power@F@I
.limit stack 4
.limit locals 209
LOAD_ARG 1 ; Copy arg 'base' to local
STORE 205
LOAD_ARG 2 ; Copy arg 'exponent' to local
STORE 206
FPUSH 1.0
STORE 207 ; Init result
LOAD 206  ; Load parameter 'exponent'
STORE 208 ; Init exp
LOAD 208  ; Load local var exp
PUSH 0
ICMP_LT
JNZ L41
JMP L42
L41:
LOAD 208  ; Load local var exp
INEG
STORE 208 ; Store to local 'exp'
L42:
L43:
LOAD 208  ; Load local var exp
PUSH 0
ICMP_GT
JNZ L44
JMP L45
L44:
LOAD 208  ; Load local var exp
PUSH 2
IDIV
PUSH 1
ICMP_EQ
JNZ L46
JMP L47
L46:
LOAD 205  ; Load parameter 'base'
STORE 207 ; Store to local 'result'
L47:
LOAD 205  ; Load parameter 'base'
STORE 205 ; Store to local 'base'
LOAD 208  ; Load local var exp
PUSH 2
IDIV
STORE 208 ; Store to local 'exp'
JMP L43
L45:
LOAD 206  ; Load parameter 'exponent'
PUSH 0
ICMP_LT
JNZ L48
JMP L49
L48:
FPUSH 1.0
LOAD 207  ; Load local var result
FDIV
STORE 207 ; Store to local 'result'
L49:
LOAD 207  ; Load local var result
RET
.endmethod

.method Arithmetic.max@I@I
.limit stack 4
.limit locals 211
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 209
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 210
LOAD 209  ; Load parameter 'a'
LOAD 210  ; Load parameter 'b'
ICMP_GT
JNZ L50
JMP L51
L50:
LOAD 209  ; Load parameter 'a'
RET
L51:
LOAD 210  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.max@F@F
.limit stack 4
.limit locals 213
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 211
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 212
LOAD 211  ; Load parameter 'a'
LOAD 212  ; Load parameter 'b'
FCMP_GT
JNZ L52
JMP L53
L52:
LOAD 211  ; Load parameter 'a'
RET
L53:
LOAD 212  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.max@F@F
.limit stack 4
.limit locals 215
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 213
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 214
LOAD 213  ; Load parameter 'a'
LOAD 214  ; Load parameter 'b'
FCMP_GT
JNZ L54
JMP L55
L54:
LOAD 213  ; Load parameter 'a'
RET
L55:
LOAD 214  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@I@I
.limit stack 4
.limit locals 217
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 215
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 216
LOAD 215  ; Load parameter 'a'
LOAD 216  ; Load parameter 'b'
ICMP_LT
JNZ L56
JMP L57
L56:
LOAD 215  ; Load parameter 'a'
RET
L57:
LOAD 216  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@F@F
.limit stack 4
.limit locals 219
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 217
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 218
LOAD 217  ; Load parameter 'a'
LOAD 218  ; Load parameter 'b'
FCMP_LT
JNZ L58
JMP L59
L58:
LOAD 217  ; Load parameter 'a'
RET
L59:
LOAD 218  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.min@F@F
.limit stack 4
.limit locals 221
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 219
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 220
LOAD 219  ; Load parameter 'a'
LOAD 220  ; Load parameter 'b'
FCMP_GT
JNZ L60
JMP L61
L60:
LOAD 219  ; Load parameter 'a'
RET
L61:
LOAD 220  ; Load parameter 'b'
RET
.endmethod

.method Arithmetic.Arithmetic
.limit stack 10
.limit locals 1
RET
.endmethod
