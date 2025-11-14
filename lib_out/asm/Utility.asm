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
.limit locals 77
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 74
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 75
LOAD 74  ; Load parameter 'a'
STORE 76 ; Init temp
LOAD 75  ; Load parameter 'b'
STORE 74 ; Store to local 'a'
LOAD 76  ; Load local var temp
STORE 75 ; Store to local 'b'
RET
.endmethod

.method Utility.swap@F@F
.limit stack 4
.limit locals 80
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 77
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 78
LOAD 77  ; Load parameter 'a'
STORE 79 ; Init temp
LOAD 78  ; Load parameter 'b'
STORE 77 ; Store to local 'a'
LOAD 79  ; Load local var temp
STORE 78 ; Store to local 'b'
RET
.endmethod

.method Utility.swap2@C@C
.limit stack 4
.limit locals 83
LOAD_ARG 1 ; Copy arg 'a' to local
STORE 80
LOAD_ARG 2 ; Copy arg 'b' to local
STORE 81
LOAD 80  ; Load parameter 'a'
STORE 82 ; Init temp
LOAD 81  ; Load parameter 'b'
STORE 80 ; Store to local 'a'
LOAD 82  ; Load local var temp
STORE 81 ; Store to local 'b'
RET
.endmethod

.method Utility.Utility
.limit stack 10
.limit locals 1
RET
.endmethod

.method Algorithms.insert@[I@I@I@I
.limit stack 4
.limit locals 88
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 83
LOAD_ARG 2 ; Copy arg 'n' to local
STORE 84
LOAD_ARG 3 ; Copy arg 'pos' to local
STORE 85
LOAD_ARG 4 ; Copy arg 'value' to local
STORE 86
LOAD 85  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L0
JMP L2
L2:
LOAD 85  ; Load parameter 'pos'
LOAD 84  ; Load parameter 'n'
ICMP_GT
JNZ L0
JMP L1
L0:
RET
L1:
LOAD 84  ; Load parameter 'n'
STORE 87 ; Init i
L3:
LOAD 87  ; Load local var i
LOAD 85  ; Load parameter 'pos'
ICMP_GT
JNZ L4
JMP L5
L4:
LOAD 83 ; Load array parameter 'arr'
LOAD 87  ; Load local var i
LOAD 83 ; Load array parameter 'arr'
LOAD 87  ; Load local var i
PUSH 1
ISUB
ALOAD
ASTORE ; Store to array element
LOAD 87  ; Load local var i
PUSH 1
ISUB
STORE 87 ; Store to local 'i'
JMP L3
L5:
LOAD 83 ; Load array parameter 'arr'
LOAD 85  ; Load parameter 'pos'
LOAD 86  ; Load parameter 'value'
ASTORE ; Store to array element
LOAD_ARG 84 ; Load param 'n'
DUP
PUSH 1
IADD ; ++
STORE 84 ; Store param 'n'
POP
RET
.endmethod

.method Algorithms.sort@[I@I
.limit stack 4
.limit locals 92
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 88
LOAD_ARG 2 ; Copy arg 'n' to local
STORE 89
PUSH 0
STORE 90 ; Init i
L6:
LOAD 90  ; Load local var i
LOAD 89  ; Load parameter 'n'
PUSH 1
ISUB
ICMP_LT
JNZ L7
JMP L8
L7:
PUSH 0
STORE 91 ; Init j
L9:
LOAD 91  ; Load local var j
LOAD 89  ; Load parameter 'n'
LOAD 90  ; Load local var i
ISUB
PUSH 1
ISUB
ICMP_LT
JNZ L10
JMP L11
L10:
LOAD 88 ; Load array parameter 'arr'
LOAD 91  ; Load local var j
ALOAD
LOAD 88 ; Load array parameter 'arr'
LOAD 91  ; Load local var j
PUSH 1
IADD
ALOAD
ICMP_GT
JNZ L12
JMP L13
L12:
LOAD 88 ; Load array parameter 'arr'
LOAD 91  ; Load local var j
PUSH 1
IADD
ALOAD
LOAD 88 ; Load array parameter 'arr'
LOAD 91  ; Load local var j
ALOAD
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
INVOKEVIRTUAL 0 3; Call Utility.swap@I@I
POP ; discard fp
L13:
LOAD 91  ; Load local var j
PUSH 1
IADD
STORE 91 ; Store to local 'j'
JMP L9
L11:
LOAD 90  ; Load local var i
PUSH 1
IADD
STORE 90 ; Store to local 'i'
JMP L6
L8:
RET
.endmethod

.method Algorithms.reverse@[I@I
.limit stack 4
.limit locals 96
LOAD_ARG 1 ; Copy arg 'arr' to local
STORE 92
LOAD_ARG 2 ; Copy arg 'n' to local
STORE 93
PUSH 0
STORE 94 ; Init start
LOAD 93  ; Load parameter 'n'
PUSH 1
ISUB
STORE 95 ; Init end
L14:
LOAD 94  ; Load local var start
LOAD 95  ; Load local var end
ICMP_LT
JNZ L15
JMP L16
L15:
LOAD 92 ; Load array parameter 'arr'
LOAD 95  ; Load local var end
ALOAD
LOAD 92 ; Load array parameter 'arr'
LOAD 94  ; Load local var start
ALOAD
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
INVOKEVIRTUAL 0 3; Call Utility.swap@I@I
POP ; discard fp
LOAD 94  ; Load local var start
PUSH 1
IADD
STORE 94 ; Store to local 'start'
LOAD 95  ; Load local var end
PUSH 1
ISUB
STORE 95 ; Store to local 'end'
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
