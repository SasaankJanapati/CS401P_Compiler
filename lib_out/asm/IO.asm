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
.limit locals 2
PUSH 1
NEWARRAY C
STORE 0 ; Store new flattened array to 'c'
PUSH 0 ; Push address of buffer variable 'c'
PUSH 1
PUSH 0
SYS_CALL READ ; read
POP
LOAD 0 ; Load array variable 'c'
PUSH 0
ALOAD
STORE 1 ; Store to local 'ans'
LOAD 1  ; Load local var ans
RET
.endmethod

.method IOHandler.writeChar@C
.limit stack 4
.limit locals 4
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 2
PUSH 1
NEWARRAY C
STORE 3 ; Store new flattened array to 'arr'
LOAD 3 ; Load array variable 'arr'
PUSH 0
LOAD 2  ; Load parameter 'c'
ASTORE ; Store to array element
LOAD 3  ; Load local var arr
PUSH 1
PUSH 1
SYS_CALL WRITE ; write
POP
RET
.endmethod

.method IOHandler.readString@[C@I
.limit stack 4
.limit locals 8
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 4
LOAD_ARG 2 ; Copy arg 'size' to local
STORE 5
PUSH 0
STORE 6 ; Init i
L0:
LOAD 6  ; Load local var i
LOAD 5  ; Load parameter 'size'
PUSH 1
ISUB
ICMP_LT
JNZ L1
JMP L2
L1:
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 0 1; Call IOHandler.readChar
STORE 7 ; Store to local 'c'
LOAD 7  ; Load local var c
PUSH 10 ; Push ASCII for char '\n'
ICMP_EQ
JNZ L3
JMP L5
L5:
LOAD 7  ; Load local var c
PUSH 13 ; Push ASCII for char '\r'
ICMP_EQ
JNZ L3
JMP L4
L3:
JMP L2 ; BREAK
L4:
LOAD 4 ; Load array parameter 'arr'
LOAD 6  ; Load local var i
LOAD 7  ; Load local var c
ASTORE ; Store to array element
LOAD 6 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 6 ; Store local 'i'
POP
JMP L0
L2:
LOAD 4 ; Load array parameter 'arr'
LOAD 6  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method IOHandler.stringToInt@[C
.limit stack 4
.limit locals 13
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 8
PUSH 1
STORE 11 ; Init sign
PUSH 0
STORE 10 ; Init num
PUSH 0
STORE 9 ; Init i
LOAD 8 ; Load array parameter 'arr'
PUSH 0
ALOAD
PUSH 45 ; Push ASCII for char '-'
ICMP_EQ
JNZ L6
JMP L7
L6:
PUSH 1
INEG
STORE 11 ; Store to local 'sign'
LOAD 9 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 9 ; Store local 'i'
POP
L7:
L8:
LOAD 8 ; Load array parameter 'arr'
LOAD 9  ; Load local var i
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L9
JMP L10
L9:
LOAD 8 ; Load array parameter 'arr'
LOAD 9  ; Load local var i
ALOAD
PUSH 48 ; Push ASCII for char '0'
ICMP_GEQ
JNZ L14
JMP L12
L14:
LOAD 8 ; Load array parameter 'arr'
LOAD 9  ; Load local var i
ALOAD
PUSH 57 ; Push ASCII for char '9'
ICMP_LEQ
JNZ L11
JMP L12
L11:
LOAD 8 ; Load array parameter 'arr'
LOAD 9  ; Load local var i
ALOAD
STORE 12 ; Init digit
LOAD 12  ; Load local var digit
PUSH 48 ; Push ASCII for char '0'
ISUB
STORE 12 ; Store to local 'digit'
LOAD 10  ; Load local var num
PUSH 10
IMUL
LOAD 12  ; Load local var digit
IADD
STORE 10 ; Store to local 'num'
JMP L13
L12:
JMP L10 ; BREAK
L13:
LOAD 9 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 9 ; Store local 'i'
POP
JMP L8
L10:
LOAD 11  ; Load local var sign
LOAD 10  ; Load local var num
IMUL
RET
.endmethod

.method IOHandler.intToString@I@[C
.limit stack 4
.limit locals 19
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 13
LOAD_ARG 2 ; Copy arg 'arr' to local
STORE 14
PUSH 0
STORE 15 ; Init i
PUSH 0
STORE 16 ; Init isNeg
LOAD 13  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L15
JMP L16
L15:
LOAD 14 ; Load array parameter 'arr'
LOAD 15 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 15 ; Store local 'i'
PUSH 48 ; Push ASCII for char '0'
ASTORE ; Store to array element
LOAD 14 ; Load array parameter 'arr'
LOAD 15  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
L16:
LOAD 13  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L17
JMP L18
L17:
PUSH 1
STORE 16 ; Store to local 'isNeg'
LOAD 13  ; Load parameter 'x'
INEG
STORE 13 ; Store to local 'x'
L18:
L19:
LOAD 13  ; Load parameter 'x'
PUSH 0
ICMP_GT
JNZ L20
JMP L21
L20:
LOAD 14 ; Load array parameter 'arr'
LOAD 15 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 15 ; Store local 'i'
LOAD 13  ; Load parameter 'x'
PUSH 10
IMOD
PUSH 48 ; Push ASCII for char '0'
IADD
ASTORE ; Store to array element
PUSH 10
STORE 13 ; Store to local 'x'
JMP L19
L21:
LOAD 16  ; Load local var isNeg
PUSH 1
ICMP_EQ
JNZ L22
JMP L23
L22:
LOAD 14 ; Load array parameter 'arr'
LOAD 15 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 15 ; Store local 'i'
PUSH 45 ; Push ASCII for char '-'
ASTORE ; Store to array element
L23:
LOAD 14 ; Load array parameter 'arr'
LOAD 15  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
PUSH 0
STORE 17 ; Init j
JMP L24
L25:
LOAD 14 ; Load array parameter 'arr'
LOAD 17  ; Load local var j
ALOAD
STORE 18 ; Init temp
LOAD 14 ; Load array parameter 'arr'
LOAD 17  ; Load local var j
LOAD 14 ; Load array parameter 'arr'
LOAD 15  ; Load local var i
LOAD 17  ; Load local var j
ISUB
PUSH 1
ISUB
ALOAD
ASTORE ; Store to array element
LOAD 14 ; Load array parameter 'arr'
LOAD 15  ; Load local var i
LOAD 17  ; Load local var j
ISUB
PUSH 1
ISUB
LOAD 18  ; Load local var temp
ASTORE ; Store to array element
L26:
LOAD 17 ; Load local 'j'
DUP
PUSH 1
IADD ; ++
STORE 17 ; Store local 'j'
L24:
LOAD 17  ; Load local var j
LOAD 15  ; Load local var i
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
.limit locals 30
LOAD_ARG 1 ; Copy arg 'val' to local
STORE 19
LOAD_ARG 2 ; Copy arg 'arr' to local
STORE 20
PUSH 0
STORE 21 ; Init neg
LOAD 19  ; Load parameter 'val'
PUSH 0
ICMP_LT
JNZ L28
JMP L29
L28:
PUSH 1
STORE 21 ; Store to local 'neg'
LOAD 19  ; Load parameter 'val'
FNEG
STORE 19 ; Store to local 'val'
L29:
PUSH 0
STORE 22 ; Init intPart
LOAD 19  ; Load parameter 'val'
STORE 23 ; Init temp
L30:
LOAD 23  ; Load local var temp
FPUSH 1.0
FCMP_GEQ
JNZ L31
JMP L32
L31:
LOAD 23  ; Load local var temp
FPUSH 1.0
FSUB
STORE 23 ; Store to local 'temp'
LOAD 22  ; Load local var intPart
PUSH 1
IADD
STORE 22 ; Store to local 'intPart'
JMP L30
L32:
LOAD 19  ; Load parameter 'val'
LOAD 22  ; Load local var intPart
FSUB
STORE 24 ; Init frac
PUSH 50
NEWARRAY C
STORE 25 ; Store new flattened array to 'intBuf'
LOAD 25  ; Load local var intBuf
LOAD 22  ; Load local var intPart
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 4 3; Call IOHandler.intToString@I@[C
POP ; discard fp
PUSH 0
STORE 27 ; Init j
PUSH 0
STORE 26 ; Init i
LOAD 21  ; Load local var neg
PUSH 1
ICMP_EQ
JNZ L33
JMP L34
L33:
LOAD 20 ; Load array parameter 'arr'
LOAD 26 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 26 ; Store local 'i'
PUSH 45 ; Push ASCII for char '-'
ASTORE ; Store to array element
L34:
L35:
LOAD 25 ; Load array variable 'intBuf'
LOAD 27  ; Load local var j
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L36
JMP L37
L36:
LOAD 20 ; Load array parameter 'arr'
LOAD 26 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 26 ; Store local 'i'
LOAD 25 ; Load array variable 'intBuf'
LOAD 27 ; Load local 'j'
DUP
PUSH 1
IADD ; ++
STORE 27 ; Store local 'j'
ALOAD
ASTORE ; Store to array element
JMP L35
L37:
LOAD 20 ; Load array parameter 'arr'
LOAD 26 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 26 ; Store local 'i'
PUSH 46 ; Push ASCII for char '.'
ASTORE ; Store to array element
PUSH 0
STORE 28 ; Init k
JMP L38
L39:
LOAD 24  ; Load local var frac
FPUSH 10.0
FMUL
STORE 24 ; Store to local 'frac'
PUSH 0
STORE 29 ; Init digit
L42:
LOAD 24  ; Load local var frac
FPUSH 1.0
FCMP_GEQ
JNZ L43
JMP L44
L43:
LOAD 24  ; Load local var frac
FPUSH 1.0
FSUB
STORE 24 ; Store to local 'frac'
LOAD 29  ; Load local var digit
PUSH 1
IADD
STORE 29 ; Store to local 'digit'
JMP L42
L44:
LOAD 20 ; Load array parameter 'arr'
LOAD 26 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 26 ; Store local 'i'
PUSH 48 ; Push ASCII for char '0'
LOAD 29  ; Load local var digit
IADD
ASTORE ; Store to array element
L40:
LOAD 28 ; Load local 'k'
DUP
PUSH 1
IADD ; ++
STORE 28 ; Store local 'k'
L38:
LOAD 28  ; Load local var k
PUSH 6
ICMP_LT
JNZ L39
JMP L41
L41:
LOAD 20 ; Load array parameter 'arr'
LOAD 26  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method IOHandler.readInt
.limit stack 4
.limit locals 31
PUSH 50
NEWARRAY C
STORE 30 ; Store new flattened array to 'buf'
PUSH 50
LOAD 30  ; Load local var buf
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 2 3; Call IOHandler.readString@[C@I
POP ; discard fp
LOAD 30  ; Load local var buf
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 3 2; Call IOHandler.stringToInt@[C
RET
.endmethod

.method IOHandler.printString@[C
.limit stack 4
.limit locals 33
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 31
PUSH 0
STORE 32 ; Init i
L45:
LOAD 31 ; Load array parameter 'arr'
LOAD 32  ; Load local var i
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L46
JMP L47
L46:
LOAD 31 ; Load array parameter 'arr'
LOAD 32  ; Load local var i
ALOAD
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 1 2; Call IOHandler.writeChar@C
POP ; discard fp
LOAD 32 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 32 ; Store local 'i'
POP
JMP L45
L47:
RET
.endmethod

.method IOHandler.printInt@I
.limit stack 4
.limit locals 35
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 33
PUSH 50
NEWARRAY C
STORE 34 ; Store new flattened array to 'buf'
LOAD 34  ; Load local var buf
LOAD 33  ; Load parameter 'x'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 4 3; Call IOHandler.intToString@I@[C
POP ; discard fp
LOAD 34  ; Load local var buf
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 7 2; Call IOHandler.printString@[C
POP ; discard fp
RET
.endmethod

.method IOHandler.printDouble@F
.limit stack 4
.limit locals 37
LOAD_ARG 1 ; Copy arg 'x' to local
STORE 35
PUSH 100
NEWARRAY C
STORE 36 ; Store new flattened array to 'buf'
LOAD 36  ; Load local var buf
LOAD 35  ; Load parameter 'x'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 5 3; Call IOHandler.doubleToString@F@[C
POP ; discard fp
LOAD 36  ; Load local var buf
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
