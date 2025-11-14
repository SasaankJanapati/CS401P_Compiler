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
.limit locals 182
LOAD_ARG 1 ; Copy arg 'str' to local
STORE 180
PUSH 0
STORE 181 ; Init len
L0:
LOAD 180 ; Load array parameter 'str'
LOAD 181  ; Load local var len
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L1
JMP L2
L1:
LOAD 181 ; Load local 'len'
DUP
PUSH 1
IADD ; ++
STORE 181 ; Store local 'len'
POP
JMP L0
L2:
LOAD 181  ; Load local var len
RET
.endmethod

.method StringHandler.substr@[C@I@I@[C
.limit stack 4
.limit locals 188
LOAD_ARG 1 ; Copy arg 'str' to local
STORE 182
LOAD_ARG 2 ; Copy arg 'start' to local
STORE 183
LOAD_ARG 3 ; Copy arg 'len' to local
STORE 184
LOAD_ARG 4 ; Copy arg 'res' to local
STORE 185
LOAD 182  ; Load parameter 'str'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 0 2; Call StringHandler.length@[C
STORE 186 ; Init n
LOAD 183  ; Load parameter 'start'
PUSH 0
ICMP_LT
JNZ L3
JMP L5
L5:
LOAD 183  ; Load parameter 'start'
LOAD 186  ; Load local var n
ICMP_GEQ
JNZ L3
JMP L4
L3:
LOAD 185 ; Load array parameter 'res'
PUSH 0
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
L4:
PUSH 0
STORE 187 ; Store to local 'i'
JMP L6
L7:
LOAD 185 ; Load array parameter 'res'
LOAD 187  ; Load local var i
LOAD 182 ; Load array parameter 'str'
LOAD 183  ; Load parameter 'start'
LOAD 187  ; Load local var i
IADD
ALOAD
ASTORE ; Store to array element
L8:
LOAD 187 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 187 ; Store local 'i'
L6:
LOAD 187  ; Load local var i
LOAD 184  ; Load parameter 'len'
ICMP_LT
JNZ L10
JMP L9
L10:
LOAD 183  ; Load parameter 'start'
LOAD 187  ; Load local var i
IADD
LOAD 186  ; Load local var n
ICMP_LT
JNZ L7
JMP L9
L9:
LOAD 185 ; Load array parameter 'res'
LOAD 187  ; Load local var i
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.compare@[C@[C
.limit stack 4
.limit locals 191
LOAD_ARG 1 ; Copy arg 's1' to local
STORE 188
LOAD_ARG 2 ; Copy arg 's2' to local
STORE 189
PUSH 0
STORE 190 ; Init i
L11:
LOAD 188 ; Load array parameter 's1'
LOAD 190  ; Load local var i
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L14
JMP L13
L14:
LOAD 189 ; Load array parameter 's2'
LOAD 190  ; Load local var i
ALOAD
PUSH 0 ; Push ASCII for char '\0'
ICMP_NEQ
JNZ L12
JMP L13
L12:
LOAD 188 ; Load array parameter 's1'
LOAD 190  ; Load local var i
ALOAD
LOAD 189 ; Load array parameter 's2'
LOAD 190  ; Load local var i
ALOAD
ICMP_GT
JNZ L15
JMP L16
L15:
PUSH 1
RET
JMP L17
L16:
LOAD 188 ; Load array parameter 's1'
LOAD 190  ; Load local var i
ALOAD
LOAD 189 ; Load array parameter 's2'
LOAD 190  ; Load local var i
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
LOAD 190 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 190 ; Store local 'i'
POP
JMP L11
L13:
PUSH 0
RET
.endmethod

.method StringHandler.insert@[C@I@C
.limit stack 4
.limit locals 196
LOAD_ARG 1 ; Copy arg 'str' to local
STORE 191
LOAD_ARG 2 ; Copy arg 'pos' to local
STORE 192
LOAD_ARG 3 ; Copy arg 'c' to local
STORE 193
LOAD 191  ; Load parameter 'str'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 0 2; Call StringHandler.length@[C
STORE 194 ; Init n
LOAD 192  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L20
JMP L21
L20:
PUSH 0
STORE 192 ; Store to local 'pos'
L21:
LOAD 192  ; Load parameter 'pos'
LOAD 194  ; Load local var n
ICMP_GT
JNZ L22
JMP L23
L22:
LOAD 194  ; Load local var n
STORE 192 ; Store to local 'pos'
L23:
LOAD 194  ; Load local var n
STORE 195 ; Init i
JMP L24
L25:
LOAD 191 ; Load array parameter 'str'
LOAD 195  ; Load local var i
PUSH 1
IADD
LOAD 191 ; Load array parameter 'str'
LOAD 195  ; Load local var i
ALOAD
ASTORE ; Store to array element
L26:
LOAD 195 ; Load local 'i'
DUP
PUSH 1
ISUB ; --
STORE 195 ; Store local 'i'
L24:
LOAD 195  ; Load local var i
LOAD 192  ; Load parameter 'pos'
ICMP_GEQ
JNZ L25
JMP L27
L27:
LOAD 191 ; Load array parameter 'str'
LOAD 192  ; Load parameter 'pos'
LOAD 193  ; Load parameter 'c'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.erase@[C@I@I
.limit stack 4
.limit locals 201
LOAD_ARG 1 ; Copy arg 'str' to local
STORE 196
LOAD_ARG 2 ; Copy arg 'pos' to local
STORE 197
LOAD_ARG 3 ; Copy arg 'len' to local
STORE 198
LOAD 196  ; Load parameter 'str'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 0 2; Call StringHandler.length@[C
STORE 199 ; Init n
LOAD 197  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L28
JMP L30
L30:
LOAD 197  ; Load parameter 'pos'
LOAD 199  ; Load local var n
ICMP_GEQ
JNZ L28
JMP L29
L28:
RET
L29:
LOAD 197  ; Load parameter 'pos'
STORE 200 ; Init i
JMP L31
L32:
LOAD 196 ; Load array parameter 'str'
LOAD 200  ; Load local var i
LOAD 196 ; Load array parameter 'str'
LOAD 200  ; Load local var i
LOAD 198  ; Load parameter 'len'
IADD
ALOAD
ASTORE ; Store to array element
L33:
LOAD 200 ; Load local 'i'
DUP
PUSH 1
IADD ; ++
STORE 200 ; Store local 'i'
L31:
LOAD 200  ; Load local var i
LOAD 198  ; Load parameter 'len'
IADD
LOAD 199  ; Load local var n
ICMP_LT
JNZ L32
JMP L34
L34:
LOAD 196 ; Load array parameter 'str'
LOAD 199  ; Load local var n
LOAD 198  ; Load parameter 'len'
ISUB
PUSH 0 ; Push ASCII for char '\0'
ASTORE ; Store to array element
RET
.endmethod

.method StringHandler.islower@C
.limit stack 4
.limit locals 202
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 201
LOAD 201  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
ICMP_GEQ
JNZ L38
JMP L36
L38:
LOAD 201  ; Load parameter 'c'
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
.limit locals 203
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 202
LOAD 202  ; Load parameter 'c'
PUSH 65 ; Push ASCII for char 'A'
ICMP_GEQ
JNZ L42
JMP L40
L42:
LOAD 202  ; Load parameter 'c'
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
.limit locals 204
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 203
LOAD 203  ; Load parameter 'c'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 6 2; Call StringHandler.isupper@C
PUSH 1
ICMP_EQ
JNZ L43
JMP L44
L43:
LOAD 203  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
PUSH 65 ; Push ASCII for char 'A'
ISUB
IADD
RET
L44:
LOAD 203  ; Load parameter 'c'
RET
.endmethod

.method StringHandler.toupper@C
.limit stack 4
.limit locals 205
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 204
LOAD 204  ; Load parameter 'c'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 5 2; Call StringHandler.islower@C
PUSH 1
ICMP_EQ
JNZ L45
JMP L46
L45:
LOAD 204  ; Load parameter 'c'
PUSH 97 ; Push ASCII for char 'a'
PUSH 65 ; Push ASCII for char 'A'
ISUB
ISUB
RET
L46:
LOAD 204  ; Load parameter 'c'
RET
.endmethod

.method StringHandler.isalpha@C
.limit stack 4
.limit locals 206
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 205
LOAD 205  ; Load parameter 'c'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 5 2; Call StringHandler.islower@C
PUSH 1
ICMP_EQ
JNZ L47
JMP L50
L50:
LOAD 205  ; Load parameter 'c'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 6 2; Call StringHandler.isupper@C
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
.limit locals 207
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 206
LOAD 206  ; Load parameter 'c'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 9 2; Call StringHandler.isalpha@C
PUSH 1
ICMP_EQ
JNZ L51
JMP L54
L54:
LOAD 206  ; Load parameter 'c'
LOAD_ARG 0 ; Load 'this' for method call
LOAD_ARG 0 ; vm identification
INVOKEVIRTUAL 11 2; Call StringHandler.isnum@C
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
.limit locals 208
LOAD_ARG 1 ; Copy arg 'c' to local
STORE 207
LOAD 207  ; Load parameter 'c'
PUSH 48 ; Push ASCII for char '0'
ICMP_GEQ
JNZ L58
JMP L56
L58:
LOAD 207  ; Load parameter 'c'
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
