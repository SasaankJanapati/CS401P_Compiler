.class_metadata
class_count 3
class_begin VectorInt None
field_count 2
field arr [I 3
field vsize I 0
method_count 9
method VectorInt VectorInt.VectorInt
method push_back VectorInt.push_back@I
method pop_back VectorInt.pop_back
method size VectorInt.size
method at VectorInt.at@I
method set VectorInt.set@I@I
method clear VectorInt.clear
method empty VectorInt.empty
method print VectorInt.print
class_end
class_begin VectorFloat None
field_count 2
field arr [F 3
field vsize I 0
method_count 9
method VectorFloat VectorFloat.VectorFloat
method push_back VectorFloat.push_back@F
method pop_back VectorFloat.pop_back
method size VectorFloat.size
method at VectorFloat.at@I
method set VectorFloat.set@I@F
method clear VectorFloat.clear
method empty VectorFloat.empty
method print VectorFloat.print
class_end
class_begin VectorChar None
field_count 2
field arr [C 3
field vsize I 0
method_count 9
method VectorChar VectorChar.VectorChar
method push_back VectorChar.push_back@C
method pop_back VectorChar.pop_back
method size VectorChar.size
method at VectorChar.at@I
method set VectorChar.set@I@C
method clear VectorChar.clear
method empty VectorChar.empty
method print VectorChar.print
class_end
.end_metadata

.code

.method writeChar@C
.limit stack 4
.limit locals 2
LOAD_ARG 0 ; Copy arg 'c' to local
STORE 0
PUSH 1
NEWARRAY C
STORE 1 ; Store new flattened array to 'buf'
LOAD 1 ; Load array variable 'buf'
PUSH 0
LOAD 0  ; Load parameter 'c'
ASTORE ; Store to array element
LOAD 1  ; Load local var buf
PUSH 1
PUSH 1
SYS_CALL WRITE ; write
POP
RET
.endmethod

.method writeString@[C
.limit stack 4
.limit locals 4
LOAD_ARG 0 ; Copy arg 'arr' to local
STORE 2
PUSH 0
STORE 3 ; Init i
L0:
LOAD_ARG 2 ; Load array parameter 'arr'
LOAD 3  ; Load local var i
ALOAD
PUSH 92 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L1
JMP L2
L1:
LOAD_ARG 2 ; Load array parameter 'arr'
LOAD 3  ; Load local var i
ALOAD
CALL writeChar@C
LOAD 3 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 3 ; Store local 'i'
POP
JMP L0
L2:
RET
.endmethod

.method intToString@I@[C
.limit stack 4
.limit locals 10
LOAD_ARG 0 ; Copy arg 'x' to local
STORE 4
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 5
PUSH 0
STORE 7 ; Init neg
PUSH 0
STORE 6 ; Init i
LOAD 4  ; Load parameter 'x'
PUSH 0
ICMP_EQ
JNZ L3
JMP L4
L3:
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 6 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 6 ; Store local 'i'
PUSH 48 ; Push ASCII for char '0'
ASTORE ; Store to array element
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 6  ; Load local var i
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
L4:
LOAD 4  ; Load parameter 'x'
PUSH 0
ICMP_LT
JNZ L5
JMP L6
L5:
PUSH 1
STORE 7 ; Store to local 'neg'
LOAD 4  ; Load parameter 'x'
INEG
STORE 4 ; Store to local 'x'
L6:
L7:
LOAD 4  ; Load parameter 'x'
PUSH 0
ICMP_GT
JNZ L8
JMP L9
L8:
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 6 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 6 ; Store local 'i'
LOAD 4  ; Load parameter 'x'
PUSH 10
IMOD
PUSH 48 ; Push ASCII for char '0'
IADD
ASTORE ; Store to array element
PUSH 10
STORE 4 ; Store to local 'x'
JMP L7
L9:
LOAD 7  ; Load local var neg
PUSH 1
ICMP_EQ
JNZ L10
JMP L11
L10:
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 6 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 6 ; Store local 'i'
PUSH 45 ; Push ASCII for char '-'
ASTORE ; Store to array element
L11:
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 6  ; Load local var i
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
PUSH 0
STORE 8 ; Init j
JMP L12
L13:
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 8  ; Load local var j
ALOAD
STORE 9 ; Init tmp
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 8  ; Load local var j
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 6  ; Load local var i
LOAD 8  ; Load local var j
ISUB
PUSH 1
ISUB
ALOAD
ASTORE ; Store to array element
LOAD_ARG 5 ; Load array parameter 'arr'
LOAD 6  ; Load local var i
LOAD 8  ; Load local var j
ISUB
PUSH 1
ISUB
LOAD 9  ; Load local var tmp
ASTORE ; Store to array element
L14:
LOAD 8 ; Load local 'j'
DUP
PUSH 1
IADD ; ++
STORE 8 ; Store local 'j'
L12:
LOAD 8  ; Load local var j
LOAD 6  ; Load local var i
PUSH 2
IDIV
ICMP_LT
JNZ L13
JMP L15
L15:
RET
.endmethod

.method doubleToString@F@[C
.limit stack 4
.limit locals 21
LOAD_ARG 0 ; Copy arg 'val' to local
STORE 10
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 11
PUSH 0
STORE 12 ; Init neg
LOAD 10  ; Load parameter 'val'
PUSH 0
ICMP_LT
JNZ L16
JMP L17
L16:
PUSH 1
STORE 12 ; Store to local 'neg'
LOAD 10  ; Load parameter 'val'
FNEG
STORE 10 ; Store to local 'val'
L17:
PUSH 0
STORE 13 ; Init intPart
LOAD 10  ; Load parameter 'val'
STORE 14 ; Init temp
L18:
LOAD 14  ; Load local var temp
FPUSH 1.0
FCMP_GEQ
JNZ L19
JMP L20
L19:
LOAD 14  ; Load local var temp
FPUSH 1.0
FSUB
STORE 14 ; Store to local 'temp'
LOAD 13  ; Load local var intPart
PUSH 1
IADD
STORE 13 ; Store to local 'intPart'
JMP L18
L20:
LOAD 10  ; Load parameter 'val'
LOAD 13  ; Load local var intPart
FSUB
STORE 15 ; Init frac
PUSH 50
NEWARRAY C
STORE 16 ; Store new flattened array to 'intBuf'
LOAD 13  ; Load local var intPart
LOAD 16  ; Load local var intBuf
CALL intToString@I@[C
PUSH 0
STORE 18 ; Init j
PUSH 0
STORE 17 ; Init i
LOAD 12  ; Load local var neg
PUSH 1
ICMP_EQ
JNZ L21
JMP L22
L21:
LOAD_ARG 11 ; Load array parameter 'arr'
LOAD 17 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 17 ; Store local 'i'
PUSH 45 ; Push ASCII for char '-'
ASTORE ; Store to array element
L22:
L23:
LOAD 16 ; Load array variable 'intBuf'
LOAD 18  ; Load local var j
ALOAD
PUSH 92 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L24
JMP L25
L24:
LOAD_ARG 11 ; Load array parameter 'arr'
LOAD 17 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 17 ; Store local 'i'
LOAD 16 ; Load array variable 'intBuf'
LOAD 18 ; Load local 'j'
DUP
PUSH 1
IADD ; ++
STORE 18 ; Store local 'j'
ALOAD
ASTORE ; Store to array element
JMP L23
L25:
LOAD_ARG 11 ; Load array parameter 'arr'
LOAD 17 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 17 ; Store local 'i'
PUSH 46 ; Push ASCII for char '.'
ASTORE ; Store to array element
PUSH 0
STORE 19 ; Init k
JMP L26
L27:
LOAD 15  ; Load local var frac
FPUSH 10.0
FMUL
STORE 15 ; Store to local 'frac'
PUSH 0
STORE 20 ; Init digit
L30:
LOAD 15  ; Load local var frac
FPUSH 1.0
FCMP_GEQ
JNZ L31
JMP L32
L31:
LOAD 15  ; Load local var frac
FPUSH 1.0
FSUB
STORE 15 ; Store to local 'frac'
LOAD 20  ; Load local var digit
PUSH 1
IADD
STORE 20 ; Store to local 'digit'
JMP L30
L32:
LOAD_ARG 11 ; Load array parameter 'arr'
LOAD 17 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 17 ; Store local 'i'
PUSH 48 ; Push ASCII for char '0'
LOAD 20  ; Load local var digit
IADD
ASTORE ; Store to array element
L28:
LOAD 19 ; Load local 'k'
DUP
PUSH 1
IADD ; ++
STORE 19 ; Store local 'k'
L26:
LOAD 19  ; Load local var k
PUSH 6
ICMP_LT
JNZ L27
JMP L29
L29:
LOAD_ARG 11 ; Load array parameter 'arr'
LOAD 17  ; Load local var i
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method VectorInt.VectorInt
.limit stack 10
.limit locals 3
LOAD_ARG 0      ; Push 'this' reference for field 'arr'
PUSH 1000
NEWARRAY I
PUTFIELD 0
LOAD_ARG 0      ; Push 'this' reference for field 'vsize'
PUSH 0      ; Default value for 'vsize'
LOAD_ARG 0 ; 'this' for assignment to member 'vsize'
PUSH 0
PUTFIELD 1
RET
.endmethod

.method VectorInt.push_back@I
.limit stack 4
.limit locals 22
LOAD_ARG 0 ; Copy arg 'val' to local
STORE 21
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 1000
ICMP_LT
JNZ L33
JMP L34
L33:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
LOAD 21  ; Load parameter 'val'
ASTORE ; Store to array element
LOAD -1 ; Load local 'vsize'
DUP
PUSH 1
IADD ; ++
STORE -1 ; Store local 'vsize'
POP
L34:
RET
.endmethod

.method VectorInt.pop_back
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 0
ICMP_GT
JNZ L35
JMP L36
L35:
LOAD -1 ; Load local 'vsize'
DUP
PUSH 1
ISUB ; --
STORE -1 ; Store local 'vsize'
POP
L36:
RET
.endmethod

.method VectorInt.size
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
RET
.endmethod

.method VectorInt.at@I
.limit stack 4
.limit locals 23
LOAD_ARG 0 ; Copy arg 'index' to local
STORE 22
LOAD 22  ; Load parameter 'index'
PUSH 0
ICMP_LT
JNZ L37
JMP L39
L39:
LOAD 22  ; Load parameter 'index'
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_GEQ
JNZ L37
JMP L38
L37:
PUSH 1
INEG
RET
L38:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 22  ; Load parameter 'index'
ALOAD
RET
.endmethod

.method VectorInt.set@I@I
.limit stack 4
.limit locals 25
LOAD_ARG 0 ; Copy arg 'index' to local
STORE 23
LOAD_ARG 1 ; Copy arg 'val' to local
STORE 24
LOAD 23  ; Load parameter 'index'
PUSH 0
ICMP_LT
JNZ L40
JMP L42
L42:
LOAD 23  ; Load parameter 'index'
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_GEQ
JNZ L40
JMP L41
L40:
RET
L41:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 23  ; Load parameter 'index'
LOAD 24  ; Load parameter 'val'
ASTORE ; Store to array element
RET
.endmethod

.method VectorInt.clear
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; 'this' for assignment to member 'vsize'
PUSH 0
PUTFIELD 1
RET
.endmethod

.method VectorInt.empty
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 0
ICMP_EQ
JNZ L43
JMP L44
L43: ; Return true
PUSH 1
JMP L45
L44: ; Return false
PUSH 0
L45:
RET
.endmethod

.method VectorInt.print
.limit stack 4
.limit locals 27
PUSH 0
STORE 25 ; Store to local 'i'
JMP L46
L47:
PUSH 50
NEWARRAY C
STORE 26 ; Store new flattened array to 'buf'
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 25  ; Load local var i
ALOAD
LOAD 26  ; Load local var buf
CALL intToString@I@[C
LOAD 26  ; Load local var buf
CALL writeString@[C
PUSH 32 ; Push ASCII for char ' '
CALL writeChar@C
L48:
LOAD 25 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 25 ; Store local 'i'
L46:
LOAD 25  ; Load local var i
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_LT
JNZ L47
JMP L49
L49:
PUSH 92 ; Push ASCII for char '\n'
CALL writeChar@C
RET
.endmethod

.method VectorFloat.VectorFloat
.limit stack 10
.limit locals 3
LOAD_ARG 0      ; Push 'this' reference for field 'arr'
PUSH 1000
NEWARRAY F
PUTFIELD 0
LOAD_ARG 0      ; Push 'this' reference for field 'vsize'
PUSH 0      ; Default value for 'vsize'
LOAD_ARG 0 ; 'this' for assignment to member 'vsize'
PUSH 0
PUTFIELD 1
RET
.endmethod

.method VectorFloat.push_back@F
.limit stack 4
.limit locals 28
LOAD_ARG 0 ; Copy arg 'val' to local
STORE 27
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 1000
ICMP_LT
JNZ L50
JMP L51
L50:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
LOAD 27  ; Load parameter 'val'
ASTORE ; Store to array element
LOAD -1 ; Load local 'vsize'
DUP
PUSH 1
IADD ; ++
STORE -1 ; Store local 'vsize'
POP
L51:
RET
.endmethod

.method VectorFloat.pop_back
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 0
ICMP_GT
JNZ L52
JMP L53
L52:
LOAD -1 ; Load local 'vsize'
DUP
PUSH 1
ISUB ; --
STORE -1 ; Store local 'vsize'
POP
L53:
RET
.endmethod

.method VectorFloat.size
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
RET
.endmethod

.method VectorFloat.at@I
.limit stack 4
.limit locals 29
LOAD_ARG 0 ; Copy arg 'index' to local
STORE 28
LOAD 28  ; Load parameter 'index'
PUSH 0
ICMP_LT
JNZ L54
JMP L56
L56:
LOAD 28  ; Load parameter 'index'
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_GEQ
JNZ L54
JMP L55
L54:
FPUSH 1.0
FNEG
RET
L55:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 28  ; Load parameter 'index'
ALOAD
RET
.endmethod

.method VectorFloat.set@I@F
.limit stack 4
.limit locals 31
LOAD_ARG 0 ; Copy arg 'index' to local
STORE 29
LOAD_ARG 1 ; Copy arg 'val' to local
STORE 30
LOAD 29  ; Load parameter 'index'
PUSH 0
ICMP_LT
JNZ L57
JMP L59
L59:
LOAD 29  ; Load parameter 'index'
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_GEQ
JNZ L57
JMP L58
L57:
RET
L58:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 29  ; Load parameter 'index'
LOAD 30  ; Load parameter 'val'
ASTORE ; Store to array element
RET
.endmethod

.method VectorFloat.clear
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; 'this' for assignment to member 'vsize'
PUSH 0
PUTFIELD 1
RET
.endmethod

.method VectorFloat.empty
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 0
ICMP_EQ
JNZ L60
JMP L61
L60: ; Return true
PUSH 1
JMP L62
L61: ; Return false
PUSH 0
L62:
RET
.endmethod

.method VectorFloat.print
.limit stack 4
.limit locals 33
PUSH 0
STORE 31 ; Store to local 'i'
JMP L63
L64:
PUSH 100
NEWARRAY C
STORE 32 ; Store new flattened array to 'buf'
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 31  ; Load local var i
ALOAD
LOAD 32  ; Load local var buf
CALL doubleToString@F@[C
LOAD 32  ; Load local var buf
CALL writeString@[C
PUSH 32 ; Push ASCII for char ' '
CALL writeChar@C
L65:
LOAD 31 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 31 ; Store local 'i'
L63:
LOAD 31  ; Load local var i
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_LT
JNZ L64
JMP L66
L66:
PUSH 92 ; Push ASCII for char '\n'
CALL writeChar@C
RET
.endmethod

.method VectorChar.VectorChar
.limit stack 10
.limit locals 3
LOAD_ARG 0      ; Push 'this' reference for field 'arr'
PUSH 1000
NEWARRAY C
PUTFIELD 0
LOAD_ARG 0      ; Push 'this' reference for field 'vsize'
PUSH 0      ; Default value for 'vsize'
LOAD_ARG 0 ; 'this' for assignment to member 'vsize'
PUSH 0
PUTFIELD 1
RET
.endmethod

.method VectorChar.push_back@C
.limit stack 4
.limit locals 34
LOAD_ARG 0 ; Copy arg 'val' to local
STORE 33
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 1000
ICMP_LT
JNZ L67
JMP L68
L67:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
LOAD 33  ; Load parameter 'val'
ASTORE ; Store to array element
LOAD -1 ; Load local 'vsize'
DUP
PUSH 1
IADD ; ++
STORE -1 ; Store local 'vsize'
POP
L68:
RET
.endmethod

.method VectorChar.pop_back
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 0
ICMP_GT
JNZ L69
JMP L70
L69:
LOAD -1 ; Load local 'vsize'
DUP
PUSH 1
ISUB ; --
STORE -1 ; Store local 'vsize'
POP
L70:
RET
.endmethod

.method VectorChar.size
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
RET
.endmethod

.method VectorChar.at@I
.limit stack 4
.limit locals 35
LOAD_ARG 0 ; Copy arg 'index' to local
STORE 34
LOAD 34  ; Load parameter 'index'
PUSH 0
ICMP_LT
JNZ L71
JMP L73
L73:
LOAD 34  ; Load parameter 'index'
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_GEQ
JNZ L71
JMP L72
L71:
PUSH 92 ; Push ASCII for char '\0'
RET
L72:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 34  ; Load parameter 'index'
ALOAD
RET
.endmethod

.method VectorChar.set@I@C
.limit stack 4
.limit locals 37
LOAD_ARG 0 ; Copy arg 'index' to local
STORE 35
LOAD_ARG 1 ; Copy arg 'val' to local
STORE 36
LOAD 35  ; Load parameter 'index'
PUSH 0
ICMP_LT
JNZ L74
JMP L76
L76:
LOAD 35  ; Load parameter 'index'
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_GEQ
JNZ L74
JMP L75
L74:
RET
L75:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 35  ; Load parameter 'index'
LOAD 36  ; Load parameter 'val'
ASTORE ; Store to array element
RET
.endmethod

.method VectorChar.clear
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; 'this' for assignment to member 'vsize'
PUSH 0
PUTFIELD 1
RET
.endmethod

.method VectorChar.empty
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
PUSH 0
ICMP_EQ
JNZ L77
JMP L78
L77: ; Return true
PUSH 1
JMP L79
L78: ; Return false
PUSH 0
L79:
RET
.endmethod

.method VectorChar.print
.limit stack 4
.limit locals 38
PUSH 0
STORE 37 ; Store to local 'i'
JMP L80
L81:
LOAD_ARG 0 ; Load 'this' to access member array 'arr'
GETFIELD 0
LOAD 37  ; Load local var i
ALOAD
CALL writeChar@C
PUSH 32 ; Push ASCII for char ' '
CALL writeChar@C
L82:
LOAD 37 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 37 ; Store local 'i'
L80:
LOAD 37  ; Load local var i
LOAD_ARG 0 ; Load 'this' to access member 'vsize'
GETFIELD 1
ICMP_LT
JNZ L81
JMP L83
L83:
PUSH 92 ; Push ASCII for char '\n'
CALL writeChar@C
RET
.endmethod
