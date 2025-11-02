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
LOAD_ARG 1  ; Load parameter 'a'
STORE 0 ; Init temp
LOAD_ARG 2  ; Load parameter 'b'
STORE 1 ; Store to local 'a'
LOAD 0  ; Load local var temp
STORE 2 ; Store to local 'b'
.endmethod

.method Utility.swap@F@F
.limit stack 4
.limit locals 3
LOAD_ARG 1  ; Load parameter 'a'
STORE 1 ; Init temp
LOAD_ARG 2  ; Load parameter 'b'
STORE 1 ; Store to local 'a'
LOAD 1  ; Load local var temp
STORE 2 ; Store to local 'b'
.endmethod

.method Utility.swap2@C@C
.limit stack 4
.limit locals 3
LOAD_ARG 1  ; Load parameter 'a'
STORE 2 ; Init temp
LOAD_ARG 2  ; Load parameter 'b'
STORE 1 ; Store to local 'a'
LOAD 2  ; Load local var temp
STORE 2 ; Store to local 'b'
.endmethod

.method Utility.Utility
.limit stack 10
.limit locals 1
RET
.endmethod

.method Algorithms.insert@[I@I@I@I
.limit stack 4
.limit locals 5
LOAD_ARG 3  ; Load parameter 'pos'
PUSH 0
ICMP_LT
JNZ L0
JMP L2
L2:
LOAD_ARG 3  ; Load parameter 'pos'
LOAD_ARG 2  ; Load parameter 'n'
ICMP_GT
JNZ L0
JMP L1
L0:
RET
L1:
LOAD_ARG 2  ; Load parameter 'n'
STORE 3 ; Init i
L3:
LOAD 3  ; Load local var i
LOAD_ARG 3  ; Load parameter 'pos'
ICMP_GT
JNZ L4
JMP L5
L4:
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD 3  ; Load local var i
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD 3  ; Load local var i
PUSH 1
ISUB
ALOAD
ASTORE ; Store to array element
LOAD 3  ; Load local var i
PUSH 1
ISUB
STORE 3 ; Store to local 'i'
JMP L3
L5:
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD_ARG 3  ; Load parameter 'pos'
LOAD_ARG 4  ; Load parameter 'value'
ASTORE ; Store to array element
LOAD 2 ; Load current value of n for post increment
DUP
PUSH 1
IADD
STORE 2 ; Post increment
POP
.endmethod

.method Algorithms.sort@[I@I
.limit stack 4
.limit locals 6
PUSH 0
STORE 4 ; Init i
L6:
LOAD 4  ; Load local var i
LOAD_ARG 2  ; Load parameter 'n'
PUSH 1
ISUB
ICMP_LT
JNZ L7
JMP L8
L7:
PUSH 0
STORE 5 ; Init j
L9:
LOAD 5  ; Load local var j
LOAD_ARG 2  ; Load parameter 'n'
LOAD 4  ; Load local var i
ISUB
PUSH 1
ISUB
ICMP_LT
JNZ L10
JMP L11
L10:
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD 5  ; Load local var j
ALOAD
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD 5  ; Load local var j
PUSH 1
IADD
ALOAD
ICMP_GT
JNZ L12
JMP L13
L12:
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD 5  ; Load local var j
ALOAD
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD 5  ; Load local var j
PUSH 1
IADD
ALOAD
INVOKEVIRTUAL 0 ; Call Utility.swap@I@I
L13:
LOAD 5  ; Load local var j
PUSH 1
IADD
STORE 5 ; Store to local 'j'
JMP L9
L11:
LOAD 4  ; Load local var i
PUSH 1
IADD
STORE 4 ; Store to local 'i'
JMP L6
L8:
.endmethod

.method Algorithms.reverse@[I@I
.limit stack 4
.limit locals 8
PUSH 0
STORE 6 ; Init start
LOAD_ARG 2  ; Load parameter 'n'
PUSH 1
ISUB
STORE 7 ; Init end
L14:
LOAD 6  ; Load local var start
LOAD 7  ; Load local var end
ICMP_LT
JNZ L15
JMP L16
L15:
LOAD_ARG 0 ; Load 'this' to access member object 'util'
GETFIELD 0
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD 6  ; Load local var start
ALOAD
LOAD_ARG 1 ; Load array parameter 'arr'
LOAD 7  ; Load local var end
ALOAD
INVOKEVIRTUAL 0 ; Call Utility.swap@I@I
LOAD 6  ; Load local var start
PUSH 1
IADD
STORE 6 ; Store to local 'start'
LOAD 7  ; Load local var end
PUSH 1
ISUB
STORE 7 ; Store to local 'end'
JMP L14
L16:
.endmethod

.method Algorithms.Algorithms
.limit stack 10
.limit locals 2
LOAD_ARG 0      ; Push 'this' reference for field 'util'
NEW Utility
DUP
INVOKESPECIAL 3 ; Call default ctor for Utility
PUTFIELD 0 ; Store new instance to 'util'
RET
.endmethod
