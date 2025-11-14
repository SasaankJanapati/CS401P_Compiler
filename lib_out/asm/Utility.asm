.class_metadata
class_count 2
class_begin Utility None
field_count 0
method_count 4
method swap Utility.swap@I@I
method swap Utility.swap@F@F
method swap2 Utility.swap2@C@C
method Utility Utility.Utility
class_end
class_begin Algorithms None
field_count 1
field util Utility 3
method_count 4
method insert Algorithms.insert@[I@I@I@I
method sort Algorithms.sort@[I@I
method reverse Algorithms.reverse@[I@I
method Algorithms Algorithms.Algorithms
class_end
.end_metadata

.code

.method Utility.swap@I@I
.limit stack 4
.limit locals 183
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 180
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 181
LOAD 180  ; Load parameter 'a'
STORE 182 ; Init temp
LOAD 181  ; Load parameter 'b'
STORE 180 ; Store to local 'a'
LOAD 182  ; Load local var temp
STORE 181 ; Store to local 'b'
RET
.endmethod

.method Utility.swap@F@F
.limit stack 4
.limit locals 186
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 183
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 184
LOAD 183  ; Load parameter 'a'
STORE 185 ; Init temp
LOAD 184  ; Load parameter 'b'
STORE 183 ; Store to local 'a'
LOAD 185  ; Load local var temp
STORE 184 ; Store to local 'b'
RET
.endmethod

.method Utility.swap2@C@C
.limit stack 4
.limit locals 189
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 186
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 187
LOAD 186  ; Load parameter 'a'
STORE 188 ; Init temp
LOAD 187  ; Load parameter 'b'
STORE 186 ; Store to local 'a'
LOAD 188  ; Load local var temp
STORE 187 ; Store to local 'b'
RET
.endmethod

.method Utility.Utility
.limit stack 10
.limit locals 1
RET
.endmethod

.method Algorithms.insert@[I@I@I@I
.limit stack 4
.limit locals 194
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 189
LOAD_ARG 2 ; Copy arg 'n' to local
STORE 190
LOAD_ARG 3 ; Copy arg 'pos' to local
STORE 191
LOAD_ARG 4 ; Copy arg 'value' to local
STORE 192
LOAD 191  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L0
JMP L2
L2:
LOAD 191  ; Load parameter 'pos'
LOAD 190  ; Load parameter 'n'
ICMP_GT
JNZ L0
JMP L1
L0:
RET
L1:
LOAD 190  ; Load parameter 'n'
STORE 193 ; Init i
L3:
LOAD 193  ; Load local var i
LOAD 191  ; Load parameter 'pos'
ICMP_GT
JNZ L4
JMP L5
L4:
LOAD 189 ; Load array parameter 'arr'
LOAD 193  ; Load local var i
LOAD 189 ; Load array parameter 'arr'
LOAD 193  ; Load local var i
PUSH 1
ISUB
ALOAD
ASTORE ; Store to array element
LOAD 193  ; Load local var i
PUSH 1
ISUB
STORE 193 ; Store to local 'i'
JMP L3
L5:
LOAD 189 ; Load array parameter 'arr'
LOAD 191  ; Load parameter 'pos'
LOAD 192  ; Load parameter 'value'
ASTORE ; Store to array element
LOAD_ARG 190 ; Load param 'n'
DUP
PUSH 1
IADD ; ++
STORE 190 ; Store param 'n'
POP
RET
.endmethod

.method Algorithms.sort@[I@I
.limit stack 4
.limit locals 198
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 194
LOAD_ARG 2 ; Copy arg 'n' to local
STORE 195
PUSH 0
STORE 196 ; Init i
L6:
LOAD 196  ; Load local var i
LOAD 195  ; Load parameter 'n'
PUSH 1
ISUB
ICMP_LT
JNZ L7
JMP L8
L7:
PUSH 0
STORE 197 ; Init j
L9:
LOAD 197  ; Load local var j
LOAD 195  ; Load parameter 'n'
LOAD 196  ; Load local var i
ISUB
PUSH 1
ISUB
ICMP_LT
JNZ L10
JMP L11
L10:
LOAD 194 ; Load array parameter 'arr'
LOAD 197  ; Load local var j
ALOAD
LOAD 194 ; Load array parameter 'arr'
LOAD 197  ; Load local var j
PUSH 1
IADD
ALOAD
ICMP_GT
JNZ L12
JMP L13
L12:
LOAD 194 ; Load array parameter 'arr'
LOAD 197  ; Load local var j
PUSH 1
IADD
ALOAD
LOAD 194 ; Load array parameter 'arr'
LOAD 197  ; Load local var j
ALOAD
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
INVOKEVIRTUAL 0 3; Call Utility.swap@I@I
POP ; discard fp
L13:
LOAD 197  ; Load local var j
PUSH 1
IADD
STORE 197 ; Store to local 'j'
JMP L9
L11:
LOAD 196  ; Load local var i
PUSH 1
IADD
STORE 196 ; Store to local 'i'
JMP L6
L8:
RET
.endmethod

.method Algorithms.reverse@[I@I
.limit stack 4
.limit locals 202
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 198
LOAD_ARG 2 ; Copy arg 'n' to local
STORE 199
PUSH 0
STORE 200 ; Init start
LOAD 199  ; Load parameter 'n'
PUSH 1
ISUB
STORE 201 ; Init end
L14:
LOAD 200  ; Load local var start
LOAD 201  ; Load local var end
ICMP_LT
JNZ L15
JMP L16
L15:
LOAD 198 ; Load array parameter 'arr'
LOAD 201  ; Load local var end
ALOAD
LOAD 198 ; Load array parameter 'arr'
LOAD 200  ; Load local var start
ALOAD
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
INVOKEVIRTUAL 0 3; Call Utility.swap@I@I
POP ; discard fp
LOAD 200  ; Load local var start
PUSH 1
IADD
STORE 200 ; Store to local 'start'
LOAD 201  ; Load local var end
PUSH 1
ISUB
STORE 201 ; Store to local 'end'
JMP L14
L16:
RET
.endmethod

.method Algorithms.Algorithms
.limit stack 10
.limit locals 2
LOAD_ARG 0      ; Push 'this' reference for field 'util'
NEW Utility
DUP
INVOKEVIRTUAL 3 0; Call default ctor for Utility
POP ; discard fp
PUTFIELD 0 ; Store new instance to 'util'
RET
.endmethod
