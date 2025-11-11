.class_metadata
class_count 1
class_begin StringHandler None
field_count 0
method_count 13
method length StringHandler.length@[C
method substr StringHandler.substr@[C@I@I@[C
method compare StringHandler.compare@[C@[C
method insert StringHandler.insert@[C@I@C
method erase StringHandler.erase@[C@I@I
method islower StringHandler.islower@C
method isupper StringHandler.isupper@C
method tolower StringHandler.tolower@C
method toupper StringHandler.toupper@C
method isalpha StringHandler.isalpha@C
method isalnum StringHandler.isalnum@C
method isnum StringHandler.isnum@C
method StringHandler StringHandler.StringHandler
class_end
.end_metadata

.code

.method StringHandler.length@[C
.limit stack 4
.limit locals 39
LOAD_ARG 0 ; Copy arg 'str' to local
STORE 37
PUSH 0
STORE 38 ; Init len
L0:
LOAD 37 ; Load array parameter 'str'
LOAD 38  ; Load local var len
ALOAD
PUSH 92 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L1
JMP L2
L1:
LOAD 38 ; Load local 'len'
DUP
PUSH 1
IADD ; ++
STORE 38 ; Store local 'len'
POP
JMP L0
L2:
LOAD 38  ; Load local var len
RET
.endmethod

.method StringHandler.substr@[C@I@I@[C
.limit stack 4
.limit locals 45
LOAD_ARG 0 ; Copy arg 'str' to local
STORE 39
LOAD_ARG 1 ; Copy arg 'start' to local
STORE 40
LOAD_ARG 2 ; Copy arg 'len' to local
STORE 41
LOAD_ARG 3 ; Copy arg 'res' to local
STORE 42
LOAD_ARG 0 ; Load 'this' for method call
LOAD 39  ; Load parameter 'str'
INVOKEVIRTUAL 0 1; Call StringHandler.length@[C
STORE 43 ; Init n
LOAD 40  ; Load parameter 'start'
PUSH 0
ICMP_LT
JNZ L3
JMP L5
L5:
LOAD 40  ; Load parameter 'start'
LOAD 43  ; Load local var n
ICMP_GEQ
JNZ L3
JMP L4
L3:
LOAD 42 ; Load array parameter 'res'
PUSH 0
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
L4:
PUSH 0
STORE 44 ; Store to local 'i'
JMP L6
L7:
LOAD 42 ; Load array parameter 'res'
LOAD 44  ; Load local var i
LOAD 39 ; Load array parameter 'str'
LOAD 40  ; Load parameter 'start'
LOAD 44  ; Load local var i
IADD
ALOAD
ASTORE ; Store to array element
L8:
LOAD 44 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 44 ; Store local 'i'
L6:
LOAD 44  ; Load local var i
LOAD 41  ; Load parameter 'len'
ICMP_LT
JNZ L10
JMP L9
L10:
LOAD 40  ; Load parameter 'start'
LOAD 44  ; Load local var i
IADD
LOAD 43  ; Load local var n
ICMP_LT
JNZ L7
JMP L9
L9:
LOAD 42 ; Load array parameter 'res'
LOAD 44  ; Load local var i
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.compare@[C@[C
.limit stack 4
.limit locals 48
LOAD_ARG 0 ; Copy arg 's1' to local
STORE 45
LOAD_ARG 1 ; Copy arg 's2' to local
STORE 46
PUSH 0
STORE 47 ; Init i
L11:
LOAD 45 ; Load array parameter 's1'
LOAD 47  ; Load local var i
ALOAD
PUSH 92 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L14
JMP L13
L14:
LOAD 46 ; Load array parameter 's2'
LOAD 47  ; Load local var i
ALOAD
PUSH 92 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L12
JMP L13
L12:
LOAD 45 ; Load array parameter 's1'
LOAD 47  ; Load local var i
ALOAD
LOAD 46 ; Load array parameter 's2'
LOAD 47  ; Load local var i
ALOAD
ICMP_GT
JNZ L15
JMP L16
L15:
PUSH 1
RET
JMP L17
L16:
LOAD 45 ; Load array parameter 's1'
LOAD 47  ; Load local var i
ALOAD
LOAD 46 ; Load array parameter 's2'
LOAD 47  ; Load local var i
ALOAD
ICMP_LT
JNZ L18
JMP L19
L18:
PUSH 1
INEG
RET
L19:
L17:
LOAD 47 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 47 ; Store local 'i'
POP
JMP L11
L13:
PUSH 0
RET
.endmethod

.method StringHandler.insert@[C@I@C
.limit stack 4
.limit locals 53
LOAD_ARG 0 ; Copy arg 'str' to local
STORE 48
LOAD_ARG 1 ; Copy arg 'pos' to local
STORE 49
LOAD_ARG 2 ; Copy arg 'c' to local
STORE 50
LOAD_ARG 0 ; Load 'this' for method call
LOAD 48  ; Load parameter 'str'
INVOKEVIRTUAL 0 1; Call StringHandler.length@[C
STORE 51 ; Init n
LOAD 49  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L20
JMP L21
L20:
PUSH 0
STORE 49 ; Store to local 'pos'
L21:
LOAD 49  ; Load parameter 'pos'
LOAD 51  ; Load local var n
ICMP_GT
JNZ L22
JMP L23
L22:
LOAD 51  ; Load local var n
STORE 49 ; Store to local 'pos'
L23:
LOAD 51  ; Load local var n
STORE 52 ; Init i
JMP L24
L25:
LOAD 48 ; Load array parameter 'str'
LOAD 52  ; Load local var i
PUSH 1
IADD
LOAD 48 ; Load array parameter 'str'
LOAD 52  ; Load local var i
ALOAD
ASTORE ; Store to array element
L26:
LOAD 52 ; Load local 'i'
DUP
PUSH 1
ISUB ; --
STORE 52 ; Store local 'i'
L24:
LOAD 52  ; Load local var i
LOAD 49  ; Load parameter 'pos'
ICMP_GEQ
JNZ L25
JMP L27
L27:
LOAD 48 ; Load array parameter 'str'
LOAD 49  ; Load parameter 'pos'
LOAD 50  ; Load parameter 'c'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.erase@[C@I@I
.limit stack 4
.limit locals 58
LOAD_ARG 0 ; Copy arg 'str' to local
STORE 53
LOAD_ARG 1 ; Copy arg 'pos' to local
STORE 54
LOAD_ARG 2 ; Copy arg 'len' to local
STORE 55
LOAD_ARG 0 ; Load 'this' for method call
LOAD 53  ; Load parameter 'str'
INVOKEVIRTUAL 0 1; Call StringHandler.length@[C
STORE 56 ; Init n
LOAD 54  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L28
JMP L30
L30:
LOAD 54  ; Load parameter 'pos'
LOAD 56  ; Load local var n
ICMP_GEQ
JNZ L28
JMP L29
L28:
RET
L29:
LOAD 54  ; Load parameter 'pos'
STORE 57 ; Init i
JMP L31
L32:
LOAD 53 ; Load array parameter 'str'
LOAD 57  ; Load local var i
LOAD 53 ; Load array parameter 'str'
LOAD 57  ; Load local var i
LOAD 55  ; Load parameter 'len'
IADD
ALOAD
ASTORE ; Store to array element
L33:
LOAD 57 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 57 ; Store local 'i'
L31:
LOAD 57  ; Load local var i
LOAD 55  ; Load parameter 'len'
IADD
LOAD 56  ; Load local var n
ICMP_LT
JNZ L32
JMP L34
L34:
LOAD 53 ; Load array parameter 'str'
LOAD 56  ; Load local var n
LOAD 55  ; Load parameter 'len'
ISUB
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.islower@C
.limit stack 4
.limit locals 59
LOAD_ARG 0 ; Copy arg 'c' to local
STORE 58
LOAD 58  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
ICMP_GEQ
JNZ L38
JMP L36
L38:
LOAD 58  ; Load parameter 'c'
PUSH 122 ; Push ASCII for char 'z'
ICMP_LEQ
JNZ L35
JMP L36
L35: ; Return true
PUSH 1
JMP L37
L36: ; Return false
PUSH 0
L37:
RET
.endmethod

.method StringHandler.isupper@C
.limit stack 4
.limit locals 60
LOAD_ARG 0 ; Copy arg 'c' to local
STORE 59
LOAD 59  ; Load parameter 'c'
PUSH 65 ; Push ASCII for char 'A'
ICMP_GEQ
JNZ L42
JMP L40
L42:
LOAD 59  ; Load parameter 'c'
PUSH 90 ; Push ASCII for char 'Z'
ICMP_LEQ
JNZ L39
JMP L40
L39: ; Return true
PUSH 1
JMP L41
L40: ; Return false
PUSH 0
L41:
RET
.endmethod

.method StringHandler.tolower@C
.limit stack 4
.limit locals 61
LOAD_ARG 0 ; Copy arg 'c' to local
STORE 60
LOAD_ARG 0 ; Load 'this' for method call
LOAD 60  ; Load parameter 'c'
INVOKEVIRTUAL 6 1; Call StringHandler.isupper@C
PUSH 1
ICMP_EQ
JNZ L43
JMP L44
L43:
LOAD 60  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
PUSH 65 ; Push ASCII for char 'A'
ISUB
IADD
RET
L44:
LOAD 60  ; Load parameter 'c'
RET
.endmethod

.method StringHandler.toupper@C
.limit stack 4
.limit locals 62
LOAD_ARG 0 ; Copy arg 'c' to local
STORE 61
LOAD_ARG 0 ; Load 'this' for method call
LOAD 61  ; Load parameter 'c'
INVOKEVIRTUAL 5 1; Call StringHandler.islower@C
PUSH 1
ICMP_EQ
JNZ L45
JMP L46
L45:
LOAD 61  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
PUSH 65 ; Push ASCII for char 'A'
ISUB
ISUB
RET
L46:
LOAD 61  ; Load parameter 'c'
RET
.endmethod

.method StringHandler.isalpha@C
.limit stack 4
.limit locals 63
LOAD_ARG 0 ; Copy arg 'c' to local
STORE 62
LOAD_ARG 0 ; Load 'this' for method call
LOAD 62  ; Load parameter 'c'
INVOKEVIRTUAL 5 1; Call StringHandler.islower@C
PUSH 1
ICMP_EQ
JNZ L47
JMP L50
L50:
LOAD_ARG 0 ; Load 'this' for method call
LOAD 62  ; Load parameter 'c'
INVOKEVIRTUAL 6 1; Call StringHandler.isupper@C
PUSH 1
ICMP_EQ
JNZ L47
JMP L48
L47: ; Return true
PUSH 1
JMP L49
L48: ; Return false
PUSH 0
L49:
RET
.endmethod

.method StringHandler.isalnum@C
.limit stack 4
.limit locals 64
LOAD_ARG 0 ; Copy arg 'c' to local
STORE 63
LOAD_ARG 0 ; Load 'this' for method call
LOAD 63  ; Load parameter 'c'
INVOKEVIRTUAL 9 1; Call StringHandler.isalpha@C
PUSH 1
ICMP_EQ
JNZ L51
JMP L54
L54:
LOAD_ARG 0 ; Load 'this' for method call
LOAD 63  ; Load parameter 'c'
INVOKEVIRTUAL 11 1; Call StringHandler.isnum@C
PUSH 1
ICMP_EQ
JNZ L51
JMP L52
L51: ; Return true
PUSH 1
JMP L53
L52: ; Return false
PUSH 0
L53:
RET
.endmethod

.method StringHandler.isnum@C
.limit stack 4
.limit locals 65
LOAD_ARG 0 ; Copy arg 'c' to local
STORE 64
LOAD 64  ; Load parameter 'c'
PUSH 48 ; Push ASCII for char '0'
ICMP_GEQ
JNZ L58
JMP L56
L58:
LOAD 64  ; Load parameter 'c'
PUSH 57 ; Push ASCII for char '9'
ICMP_LEQ
JNZ L55
JMP L56
L55: ; Return true
PUSH 1
JMP L57
L56: ; Return false
PUSH 0
L57:
RET
.endmethod

.method StringHandler.StringHandler
.limit stack 10
.limit locals 1
RET
.endmethod
