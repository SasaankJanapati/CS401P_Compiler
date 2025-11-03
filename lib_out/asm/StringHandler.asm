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
.limit locals 2
PUSH 0
STORE 0 ; Init len
L0:
LOAD_ARG 1 ; Load array parameter 'str'
LOAD 0  ; Load local var len
ALOAD
PUSH 92 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L1
JMP L2
L1:
LOAD 0 ; Load local 'len'
DUP
PUSH 1
IADD ; ++
STORE 0 ; Store local 'len'
POP
JMP L0
L2:
LOAD 0  ; Load local var len
RET
.endmethod

.method StringHandler.substr@[C@I@I@[C
.limit stack 4
.limit locals 5
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'str'
INVOKEVIRTUAL 0 ; Call StringHandler.length@[C
STORE 1 ; Init n
LOAD_ARG 2  ; Load parameter 'start'
PUSH 0
ICMP_LT
JNZ L3
JMP L5
L5:
LOAD_ARG 2  ; Load parameter 'start'
LOAD 1  ; Load local var n
ICMP_GEQ
JNZ L3
JMP L4
L3:
LOAD_ARG 4 ; Load array parameter 'res'
PUSH 0
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
L4:
PUSH 0
STORE 2 ; Store to local 'i'
JMP L6
L7:
LOAD_ARG 4 ; Load array parameter 'res'
LOAD 2  ; Load local var i
LOAD_ARG 1 ; Load array parameter 'str'
LOAD_ARG 2  ; Load parameter 'start'
LOAD 2  ; Load local var i
IADD
ALOAD
ASTORE ; Store to array element
L8:
LOAD 2 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 2 ; Store local 'i'
L6:
LOAD 2  ; Load local var i
LOAD_ARG 3  ; Load parameter 'len'
ICMP_LT
JNZ L10
JMP L9
L10:
LOAD_ARG 2  ; Load parameter 'start'
LOAD 2  ; Load local var i
IADD
LOAD 1  ; Load local var n
ICMP_LT
JNZ L7
JMP L9
L9:
LOAD_ARG 4 ; Load array parameter 'res'
LOAD 2  ; Load local var i
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.compare@[C@[C
.limit stack 4
.limit locals 4
PUSH 0
STORE 3 ; Init i
L11:
LOAD_ARG 1 ; Load array parameter 's1'
LOAD 3  ; Load local var i
ALOAD
PUSH 92 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L14
JMP L13
L14:
LOAD_ARG 2 ; Load array parameter 's2'
LOAD 3  ; Load local var i
ALOAD
PUSH 92 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L12
JMP L13
L12:
LOAD_ARG 1 ; Load array parameter 's1'
LOAD 3  ; Load local var i
ALOAD
LOAD_ARG 2 ; Load array parameter 's2'
LOAD 3  ; Load local var i
ALOAD
ICMP_NEQ
JNZ L15
JMP L16
L15:
LOAD_ARG 1 ; Load array parameter 's1'
LOAD 3  ; Load local var i
ALOAD
LOAD_ARG 2 ; Load array parameter 's2'
LOAD 3  ; Load local var i
ALOAD
ISUB
RET
L16:
LOAD 3 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 3 ; Store local 'i'
POP
JMP L11
L13:
LOAD_ARG 1 ; Load array parameter 's1'
LOAD 3  ; Load local var i
ALOAD
LOAD_ARG 2 ; Load array parameter 's2'
LOAD 3  ; Load local var i
ALOAD
ISUB
RET
.endmethod

.method StringHandler.insert@[C@I@C
.limit stack 4
.limit locals 6
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'str'
INVOKEVIRTUAL 0 ; Call StringHandler.length@[C
STORE 4 ; Init n
LOAD_ARG 2  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L17
JMP L18
L17:
PUSH 0
STORE 2 ; Store to local 'pos'
L18:
LOAD_ARG 2  ; Load parameter 'pos'
LOAD 4  ; Load local var n
ICMP_GT
JNZ L19
JMP L20
L19:
LOAD 4  ; Load local var n
STORE 2 ; Store to local 'pos'
L20:
LOAD 4  ; Load local var n
STORE 5 ; Init i
JMP L21
L22:
LOAD_ARG 1 ; Load array parameter 'str'
LOAD 5  ; Load local var i
PUSH 1
IADD
LOAD_ARG 1 ; Load array parameter 'str'
LOAD 5  ; Load local var i
ALOAD
ASTORE ; Store to array element
L23:
LOAD 5 ; Load local 'i'
DUP
PUSH 1
ISUB ; --
STORE 5 ; Store local 'i'
L21:
LOAD 5  ; Load local var i
LOAD_ARG 2  ; Load parameter 'pos'
ICMP_GEQ
JNZ L22
JMP L24
L24:
LOAD_ARG 1 ; Load array parameter 'str'
LOAD_ARG 2  ; Load parameter 'pos'
LOAD_ARG 3  ; Load parameter 'c'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.erase@[C@I@I
.limit stack 4
.limit locals 8
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'str'
INVOKEVIRTUAL 0 ; Call StringHandler.length@[C
STORE 6 ; Init n
LOAD_ARG 2  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L25
JMP L27
L27:
LOAD_ARG 2  ; Load parameter 'pos'
LOAD 6  ; Load local var n
ICMP_GEQ
JNZ L25
JMP L26
L25:
RET
L26:
LOAD_ARG 2  ; Load parameter 'pos'
STORE 7 ; Init i
JMP L28
L29:
LOAD_ARG 1 ; Load array parameter 'str'
LOAD 7  ; Load local var i
LOAD_ARG 1 ; Load array parameter 'str'
LOAD 7  ; Load local var i
LOAD_ARG 3  ; Load parameter 'len'
IADD
ALOAD
ASTORE ; Store to array element
L30:
LOAD 7 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 7 ; Store local 'i'
L28:
LOAD 7  ; Load local var i
LOAD_ARG 3  ; Load parameter 'len'
IADD
LOAD 6  ; Load local var n
ICMP_LT
JNZ L29
JMP L31
L31:
LOAD_ARG 1 ; Load array parameter 'str'
LOAD 6  ; Load local var n
LOAD_ARG 3  ; Load parameter 'len'
ISUB
PUSH 92 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.islower@C
.limit stack 4
.limit locals 2
LOAD_ARG 1  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
ICMP_GEQ
JNZ L35
JMP L33
L35:
LOAD_ARG 1  ; Load parameter 'c'
PUSH 122 ; Push ASCII for char 'z'
ICMP_LEQ
JNZ L32
JMP L33
L32: ; Return true
PUSH 1
JMP L34
L33: ; Return false
PUSH 0
L34:
RET
.endmethod

.method StringHandler.isupper@C
.limit stack 4
.limit locals 2
LOAD_ARG 1  ; Load parameter 'c'
PUSH 65 ; Push ASCII for char 'A'
ICMP_GEQ
JNZ L39
JMP L37
L39:
LOAD_ARG 1  ; Load parameter 'c'
PUSH 90 ; Push ASCII for char 'Z'
ICMP_LEQ
JNZ L36
JMP L37
L36: ; Return true
PUSH 1
JMP L38
L37: ; Return false
PUSH 0
L38:
RET
.endmethod

.method StringHandler.tolower@C
.limit stack 4
.limit locals 2
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'c'
INVOKEVIRTUAL 6 ; Call StringHandler.isupper@C
PUSH 1
ICMP_EQ
JNZ L40
JMP L41
L40:
LOAD_ARG 1  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
PUSH 65 ; Push ASCII for char 'A'
ISUB
IADD
RET
L41:
LOAD_ARG 1  ; Load parameter 'c'
RET
.endmethod

.method StringHandler.toupper@C
.limit stack 4
.limit locals 2
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'c'
INVOKEVIRTUAL 5 ; Call StringHandler.islower@C
PUSH 1
ICMP_EQ
JNZ L42
JMP L43
L42:
LOAD_ARG 1  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
PUSH 65 ; Push ASCII for char 'A'
ISUB
ISUB
RET
L43:
LOAD_ARG 1  ; Load parameter 'c'
RET
.endmethod

.method StringHandler.isalpha@C
.limit stack 4
.limit locals 2
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'c'
INVOKEVIRTUAL 5 ; Call StringHandler.islower@C
PUSH 1
ICMP_EQ
JNZ L44
JMP L47
L47:
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'c'
INVOKEVIRTUAL 6 ; Call StringHandler.isupper@C
PUSH 1
ICMP_EQ
JNZ L44
JMP L45
L44: ; Return true
PUSH 1
JMP L46
L45: ; Return false
PUSH 0
L46:
RET
.endmethod

.method StringHandler.isalnum@C
.limit stack 4
.limit locals 2
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'c'
INVOKEVIRTUAL 9 ; Call StringHandler.isalpha@C
PUSH 1
ICMP_EQ
JNZ L48
JMP L51
L51:
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 1  ; Load parameter 'c'
INVOKEVIRTUAL 11 ; Call StringHandler.isnum@C
PUSH 1
ICMP_EQ
JNZ L48
JMP L49
L48: ; Return true
PUSH 1
JMP L50
L49: ; Return false
PUSH 0
L50:
RET
.endmethod

.method StringHandler.isnum@C
.limit stack 4
.limit locals 2
LOAD_ARG 1  ; Load parameter 'c'
PUSH 48 ; Push ASCII for char '0'
ICMP_GEQ
JNZ L55
JMP L53
L55:
LOAD_ARG 1  ; Load parameter 'c'
PUSH 57 ; Push ASCII for char '9'
ICMP_LEQ
JNZ L52
JMP L53
L52: ; Return true
PUSH 1
JMP L54
L53: ; Return false
PUSH 0
L54:
RET
.endmethod

.method StringHandler.StringHandler
.limit stack 10
.limit locals 1
RET
.endmethod
