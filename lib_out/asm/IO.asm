.class_metadata
class_count 1
class_begin IOHandler None
field_count 0
method_count 11
method readChar IOHandler.readChar
method writeChar IOHandler.writeChar@C
method readString IOHandler.readString@[C@I
method stringToInt IOHandler.stringToInt@[C
method intToString IOHandler.intToString@I@[C
method doubleToString IOHandler.doubleToString@F@[C
method readInt IOHandler.readInt
method printString IOHandler.printString@[C
method printInt IOHandler.printInt@I
method printDouble IOHandler.printDouble@F
method IOHandler IOHandler.IOHandler
class_end
.end_metadata

.code

.method IOHandler.readChar
.limit stack 4
.limit locals 182
PUSH 1
NEWARRAY C
STORE 180 ; Store new flattened array to 'c'
PUSH 180 ; Push address of buffer variable 'c'
PUSH 1
PUSH 0
SYS_CALL READ ; read
POP
LOAD 180 ; Load array variable 'c'
PUSH 0
ALOAD
STORE 181 ; Store to local 'ans'
LOAD 181  ; Load local var ans
RET
.endmethod

.method IOHandler.writeChar@C
.limit stack 4
.limit locals 184
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 182
PUSH 1
NEWARRAY C
STORE 183 ; Store new flattened array to 'arr'
LOAD 183 ; Load array variable 'arr'
PUSH 0
LOAD 182  ; Load parameter 'c'
ASTORE ; Store to array element
LOAD 183  ; Load local var arr
PUSH 1
PUSH 1
SYS_CALL WRITE ; write
POP
RET
.endmethod

.method IOHandler.readString@[C@I
.limit stack 4
.limit locals 188
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 184
LOAD_ARG 2 ; Copy arg 'size' to local
STORE 185
PUSH 0
STORE 186 ; Init i
L0:
LOAD 186  ; Load local var i
LOAD 185  ; Load parameter 'size'
PUSH 1
ISUB
ICMP_LT
JNZ L1
JMP L2
L1:
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 0 1; Call IOHandler.readChar
STORE 187 ; Store to local 'c'
LOAD 187  ; Load local var c
PUSH 10 ; Push ASCII for char '\n'
ICMP_EQ
JNZ L3
JMP L5
L5:
LOAD 187  ; Load local var c
PUSH 13 ; Push ASCII for char '\r'
ICMP_EQ
JNZ L3
JMP L4
L3:
JMP L2 ; BREAK
L4:
LOAD 184 ; Load array parameter 'arr'
LOAD 186  ; Load local var i
LOAD 187  ; Load local var c
ASTORE ; Store to array element
LOAD 186 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 186 ; Store local 'i'
POP
JMP L0
L2:
LOAD 184 ; Load array parameter 'arr'
LOAD 186  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method IOHandler.stringToInt@[C
.limit stack 4
.limit locals 193
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 188
PUSH 1
STORE 191 ; Init sign
PUSH 0
STORE 190 ; Init num
PUSH 0
STORE 189 ; Init i
LOAD 188 ; Load array parameter 'arr'
PUSH 0
ALOAD
PUSH 45 ; Push ASCII for char '-'
ICMP_EQ
JNZ L6
JMP L7
L6:
PUSH 1
INEG
STORE 191 ; Store to local 'sign'
LOAD 189 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 189 ; Store local 'i'
POP
L7:
L8:
LOAD 188 ; Load array parameter 'arr'
LOAD 189  ; Load local var i
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L9
JMP L10
L9:
LOAD 188 ; Load array parameter 'arr'
LOAD 189  ; Load local var i
ALOAD
PUSH 48 ; Push ASCII for char '0'
ICMP_GEQ
JNZ L14
JMP L12
L14:
LOAD 188 ; Load array parameter 'arr'
LOAD 189  ; Load local var i
ALOAD
PUSH 57 ; Push ASCII for char '9'
ICMP_LEQ
JNZ L11
JMP L12
L11:
LOAD 188 ; Load array parameter 'arr'
LOAD 189  ; Load local var i
ALOAD
STORE 192 ; Init digit
LOAD 192  ; Load local var digit
PUSH 48 ; Push ASCII for char '0'
ISUB
STORE 192 ; Store to local 'digit'
LOAD 190  ; Load local var num
PUSH 10
IMUL
LOAD 192  ; Load local var digit
IADD
STORE 190 ; Store to local 'num'
JMP L13
L12:
JMP L10 ; BREAK
L13:
LOAD 189 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 189 ; Store local 'i'
POP
JMP L8
L10:
LOAD 191  ; Load local var sign
LOAD 190  ; Load local var num
IMUL
RET
.endmethod

.method IOHandler.intToString@I@[C
.limit stack 4
.limit locals 199
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 193
LOAD_ARG 2 ; Copy arg 'arr' to local
STORE 194
PUSH 0
STORE 195 ; Init i
PUSH 0
STORE 196 ; Init isNeg
LOAD 193  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L15
JMP L16
L15:
LOAD 194 ; Load array parameter 'arr'
LOAD 195 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 195 ; Store local 'i'
PUSH 48 ; Push ASCII for char '0'
ASTORE ; Store to array element
LOAD 194 ; Load array parameter 'arr'
LOAD 195  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
L16:
LOAD 193  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L17
JMP L18
L17:
PUSH 1
STORE 196 ; Store to local 'isNeg'
LOAD 193  ; Load parameter 'x'
INEG
STORE 193 ; Store to local 'x'
L18:
L19:
LOAD 193  ; Load parameter 'x'
PUSH 0
ICMP_GT
JNZ L20
JMP L21
L20:
LOAD 194 ; Load array parameter 'arr'
LOAD 195 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 195 ; Store local 'i'
LOAD 193  ; Load parameter 'x'
PUSH 10
IMOD
PUSH 48 ; Push ASCII for char '0'
IADD
ASTORE ; Store to array element
PUSH 10
STORE 193 ; Store to local 'x'
JMP L19
L21:
LOAD 196  ; Load local var isNeg
PUSH 1
ICMP_EQ
JNZ L22
JMP L23
L22:
LOAD 194 ; Load array parameter 'arr'
LOAD 195 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 195 ; Store local 'i'
PUSH 45 ; Push ASCII for char '-'
ASTORE ; Store to array element
L23:
LOAD 194 ; Load array parameter 'arr'
LOAD 195  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
PUSH 0
STORE 197 ; Init j
JMP L24
L25:
LOAD 194 ; Load array parameter 'arr'
LOAD 197  ; Load local var j
ALOAD
STORE 198 ; Init temp
LOAD 194 ; Load array parameter 'arr'
LOAD 197  ; Load local var j
LOAD 194 ; Load array parameter 'arr'
LOAD 195  ; Load local var i
LOAD 197  ; Load local var j
ISUB
PUSH 1
ISUB
ALOAD
ASTORE ; Store to array element
LOAD 194 ; Load array parameter 'arr'
LOAD 195  ; Load local var i
LOAD 197  ; Load local var j
ISUB
PUSH 1
ISUB
LOAD 198  ; Load local var temp
ASTORE ; Store to array element
L26:
LOAD 197 ; Load local 'j'
DUP
PUSH 1
IADD ; ++
STORE 197 ; Store local 'j'
L24:
LOAD 197  ; Load local var j
LOAD 195  ; Load local var i
PUSH 2
IDIV
ICMP_LT
JNZ L25
JMP L27
L27:
RET
.endmethod

.method IOHandler.doubleToString@F@[C
.limit stack 4
.limit locals 210
LOAD_ARG 1 ; Copy arg 'val' to local
STORE 199
LOAD_ARG 2 ; Copy arg 'arr' to local
STORE 200
PUSH 0
STORE 201 ; Init neg
LOAD 199  ; Load parameter 'val'
PUSH 0
ICMP_LT
JNZ L28
JMP L29
L28:
PUSH 1
STORE 201 ; Store to local 'neg'
LOAD 199  ; Load parameter 'val'
FNEG
STORE 199 ; Store to local 'val'
L29:
PUSH 0
STORE 202 ; Init intPart
LOAD 199  ; Load parameter 'val'
STORE 203 ; Init temp
L30:
LOAD 203  ; Load local var temp
FPUSH 1.0
FCMP_GEQ
JNZ L31
JMP L32
L31:
LOAD 203  ; Load local var temp
FPUSH 1.0
FSUB
STORE 203 ; Store to local 'temp'
LOAD 202  ; Load local var intPart
PUSH 1
IADD
STORE 202 ; Store to local 'intPart'
JMP L30
L32:
LOAD 199  ; Load parameter 'val'
LOAD 202  ; Load local var intPart
FSUB
STORE 204 ; Init frac
PUSH 50
NEWARRAY C
STORE 205 ; Store new flattened array to 'intBuf'
LOAD 205  ; Load local var intBuf
LOAD 202  ; Load local var intPart
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 4 3; Call IOHandler.intToString@I@[C
POP ; discard fp
PUSH 0
STORE 207 ; Init j
PUSH 0
STORE 206 ; Init i
LOAD 201  ; Load local var neg
PUSH 1
ICMP_EQ
JNZ L33
JMP L34
L33:
LOAD 200 ; Load array parameter 'arr'
LOAD 206 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 206 ; Store local 'i'
PUSH 45 ; Push ASCII for char '-'
ASTORE ; Store to array element
L34:
L35:
LOAD 205 ; Load array variable 'intBuf'
LOAD 207  ; Load local var j
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L36
JMP L37
L36:
LOAD 200 ; Load array parameter 'arr'
LOAD 206 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 206 ; Store local 'i'
LOAD 205 ; Load array variable 'intBuf'
LOAD 207 ; Load local 'j'
DUP
PUSH 1
IADD ; ++
STORE 207 ; Store local 'j'
ALOAD
ASTORE ; Store to array element
JMP L35
L37:
LOAD 200 ; Load array parameter 'arr'
LOAD 206 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 206 ; Store local 'i'
PUSH 46 ; Push ASCII for char '.'
ASTORE ; Store to array element
PUSH 0
STORE 208 ; Init k
JMP L38
L39:
LOAD 204  ; Load local var frac
FPUSH 10.0
FMUL
STORE 204 ; Store to local 'frac'
PUSH 0
STORE 209 ; Init digit
L42:
LOAD 204  ; Load local var frac
FPUSH 1.0
FCMP_GEQ
JNZ L43
JMP L44
L43:
LOAD 204  ; Load local var frac
FPUSH 1.0
FSUB
STORE 204 ; Store to local 'frac'
LOAD 209  ; Load local var digit
PUSH 1
IADD
STORE 209 ; Store to local 'digit'
JMP L42
L44:
LOAD 200 ; Load array parameter 'arr'
LOAD 206 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 206 ; Store local 'i'
PUSH 48 ; Push ASCII for char '0'
LOAD 209  ; Load local var digit
IADD
ASTORE ; Store to array element
L40:
LOAD 208 ; Load local 'k'
DUP
PUSH 1
IADD ; ++
STORE 208 ; Store local 'k'
L38:
LOAD 208  ; Load local var k
PUSH 6
ICMP_LT
JNZ L39
JMP L41
L41:
LOAD 200 ; Load array parameter 'arr'
LOAD 206  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method IOHandler.readInt
.limit stack 4
.limit locals 211
PUSH 50
NEWARRAY C
STORE 210 ; Store new flattened array to 'buf'
PUSH 50
LOAD 210  ; Load local var buf
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 2 3; Call IOHandler.readString@[C@I
POP ; discard fp
LOAD 210  ; Load local var buf
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 3 2; Call IOHandler.stringToInt@[C
RET
.endmethod

.method IOHandler.printString@[C
.limit stack 4
.limit locals 213
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 211
PUSH 0
STORE 212 ; Init i
L45:
LOAD 211 ; Load array parameter 'arr'
LOAD 212  ; Load local var i
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L46
JMP L47
L46:
LOAD 211 ; Load array parameter 'arr'
LOAD 212  ; Load local var i
ALOAD
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 2; Call IOHandler.writeChar@C
POP ; discard fp
LOAD 212 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 212 ; Store local 'i'
POP
JMP L45
L47:
RET
.endmethod

.method IOHandler.printInt@I
.limit stack 4
.limit locals 215
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 213
PUSH 50
NEWARRAY C
STORE 214 ; Store new flattened array to 'buf'
LOAD 214  ; Load local var buf
LOAD 213  ; Load parameter 'x'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 4 3; Call IOHandler.intToString@I@[C
POP ; discard fp
LOAD 214  ; Load local var buf
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 7 2; Call IOHandler.printString@[C
POP ; discard fp
RET
.endmethod

.method IOHandler.printDouble@F
.limit stack 4
.limit locals 217
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 215
PUSH 100
NEWARRAY C
STORE 216 ; Store new flattened array to 'buf'
LOAD 216  ; Load local var buf
LOAD 215  ; Load parameter 'x'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 5 3; Call IOHandler.doubleToString@F@[C
POP ; discard fp
LOAD 216  ; Load local var buf
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 7 2; Call IOHandler.printString@[C
POP ; discard fp
RET
.endmethod

.method IOHandler.IOHandler
.limit stack 10
.limit locals 1
RET
.endmethod
