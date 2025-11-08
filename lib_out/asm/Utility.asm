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
.limit locals 3
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 0
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 1
LOAD 0  ; Load parameter 'a'
STORE 2 ; Init temp
LOAD 1  ; Load parameter 'b'
STORE 0 ; Store to local 'a'
LOAD 2  ; Load local var temp
STORE 1 ; Store to local 'b'
RET
.endmethod

.method Utility.swap@F@F
.limit stack 4
.limit locals 6
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 3
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 4
LOAD 3  ; Load parameter 'a'
STORE 5 ; Init temp
LOAD 4  ; Load parameter 'b'
STORE 3 ; Store to local 'a'
LOAD 5  ; Load local var temp
STORE 4 ; Store to local 'b'
RET
.endmethod

.method Utility.swap2@C@C
.limit stack 4
.limit locals 9
LOAD_ARG 0 ; Copy arg 'a' to local
STORE 6
LOAD_ARG 1 ; Copy arg 'b' to local
STORE 7
LOAD 6  ; Load parameter 'a'
STORE 8 ; Init temp
LOAD 7  ; Load parameter 'b'
STORE 6 ; Store to local 'a'
LOAD 8  ; Load local var temp
STORE 7 ; Store to local 'b'
RET
.endmethod

.method Utility.Utility
.limit stack 10
.limit locals 1
RET
.endmethod

.method Algorithms.insert@[I@I@I@I
.limit stack 4
.limit locals 14
LOAD_ARG 0 ; Copy arg 'arr' to local
STORE 9
LOAD_ARG 1 ; Copy arg 'n' to local
STORE 10
LOAD_ARG 2 ; Copy arg 'pos' to local
STORE 11
LOAD_ARG 3 ; Copy arg 'value' to local
STORE 12
LOAD 11  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L0
JMP L2
L2:
LOAD 11  ; Load parameter 'pos'
LOAD 10  ; Load parameter 'n'
ICMP_GT
JNZ L0
JMP L1
L0:
RET
L1:
LOAD 10  ; Load parameter 'n'
STORE 13 ; Init i
L3:
LOAD 13  ; Load local var i
LOAD 11  ; Load parameter 'pos'
ICMP_GT
JNZ L4
JMP L5
L4:
LOAD_ARG 9 ; Load array parameter 'arr'
LOAD 13  ; Load local var i
LOAD_ARG 9 ; Load array parameter 'arr'
LOAD 13  ; Load local var i
PUSH 1
ISUB
ALOAD
ASTORE ; Store to array element
LOAD 13  ; Load local var i
PUSH 1
ISUB
STORE 13 ; Store to local 'i'
JMP L3
L5:
LOAD_ARG 9 ; Load array parameter 'arr'
LOAD 11  ; Load parameter 'pos'
LOAD 12  ; Load parameter 'value'
ASTORE ; Store to array element
LOAD_ARG 10 ; Load param 'n'
DUP
PUSH 1
IADD ; ++
STORE 10 ; Store param 'n'
POP
RET
.endmethod

.method Algorithms.sort@[I@I
.limit stack 4
.limit locals 18
LOAD_ARG 0 ; Copy arg 'arr' to local
STORE 14
LOAD_ARG 1 ; Copy arg 'n' to local
STORE 15
PUSH 0
STORE 16 ; Init i
L6:
LOAD 16  ; Load local var i
LOAD 15  ; Load parameter 'n'
PUSH 1
ISUB
ICMP_LT
JNZ L7
JMP L8
L7:
PUSH 0
STORE 17 ; Init j
L9:
LOAD 17  ; Load local var j
LOAD 15  ; Load parameter 'n'
LOAD 16  ; Load local var i
ISUB
PUSH 1
ISUB
ICMP_LT
JNZ L10
JMP L11
L10:
LOAD_ARG 14 ; Load array parameter 'arr'
LOAD 17  ; Load local var j
ALOAD
LOAD_ARG 14 ; Load array parameter 'arr'
LOAD 17  ; Load local var j
PUSH 1
IADD
ALOAD
ICMP_GT
JNZ L12
JMP L13
L12:
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
LOAD_ARG 14 ; Load array parameter 'arr'
LOAD 17  ; Load local var j
ALOAD
LOAD_ARG 14 ; Load array parameter 'arr'
LOAD 17  ; Load local var j
PUSH 1
IADD
ALOAD
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
INVOKEVIRTUAL 0 2; Call Utility.swap@I@I
L13:
LOAD 17  ; Load local var j
PUSH 1
IADD
STORE 17 ; Store to local 'j'
JMP L9
L11:
LOAD 16  ; Load local var i
PUSH 1
IADD
STORE 16 ; Store to local 'i'
JMP L6
L8:
RET
.endmethod

.method Algorithms.reverse@[I@I
.limit stack 4
.limit locals 22
LOAD_ARG 0 ; Copy arg 'arr' to local
STORE 18
LOAD_ARG 1 ; Copy arg 'n' to local
STORE 19
PUSH 0
STORE 20 ; Init start
LOAD 19  ; Load parameter 'n'
PUSH 1
ISUB
STORE 21 ; Init end
L14:
LOAD 20  ; Load local var start
LOAD 21  ; Load local var end
ICMP_LT
JNZ L15
JMP L16
L15:
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
LOAD_ARG 18 ; Load array parameter 'arr'
LOAD 20  ; Load local var start
ALOAD
LOAD_ARG 18 ; Load array parameter 'arr'
LOAD 21  ; Load local var end
ALOAD
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
INVOKEVIRTUAL 0 2; Call Utility.swap@I@I
LOAD 20  ; Load local var start
PUSH 1
IADD
STORE 20 ; Store to local 'start'
LOAD 21  ; Load local var end
PUSH 1
ISUB
STORE 21 ; Store to local 'end'
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
DUP ; for vm identification
INVOKEVIRTUAL 3 0; Call default ctor for Utility
PUTFIELD 0 ; Store new instance to 'util'
RET
.endmethod
