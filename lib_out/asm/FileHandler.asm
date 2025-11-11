.class_metadata
class_count 1
class_begin FileHandler None
field_count 2
field fd I 0
field isOpen I 0
method_count 6
method FileHandler FileHandler.FileHandler
method fopen FileHandler.fopen@[C@I
method fclose FileHandler.fclose
method fread FileHandler.fread@[C@I
method fwrite FileHandler.fwrite@[C@I
method is_open FileHandler.is_open
class_end
.end_metadata

.code

.method FileHandler.FileHandler
.limit stack 10
.limit locals 3
LOAD_ARG 0      ; Push 'this' reference for field 'fd'
PUSH 0      ; Default value for 'fd'
PUTFIELD 0 ; Store 0 to 'fd'
LOAD_ARG 0      ; Push 'this' reference for field 'isOpen'
PUSH 0      ; Default value for 'isOpen'
PUTFIELD 1 ; Store 0 to 'isOpen'
LOAD_ARG 0 ; 'this' for assignment to member 'fd'
PUSH 1
INEG
PUTFIELD 0
LOAD_ARG 0 ; 'this' for assignment to member 'isOpen'
PUSH 0
PUTFIELD 1
RET
.endmethod

.method FileHandler.fopen@[C@I
.limit stack 4
.limit locals 68
LOAD_ARG 0 ; Copy arg 'filename' to local
STORE 65
LOAD_ARG 1 ; Copy arg 'mode' to local
STORE 66
LOAD 66  ; Load parameter 'mode'
PUSH 0
ICMP_EQ
JNZ L0
JMP L1
L0:
PUSH 114 ; Push ASCII for char 'r'
STORE 67 ; Store to local 'flags'
JMP L2
L1:
LOAD 66  ; Load parameter 'mode'
PUSH 1
ICMP_EQ
JNZ L3
JMP L4
L3:
PUSH 119 ; Push ASCII for char 'w'
STORE 67 ; Store to local 'flags'
JMP L5
L4:
LOAD 66  ; Load parameter 'mode'
PUSH 2
ICMP_EQ
JNZ L6
JMP L7
L6:
PUSH 97 ; Push ASCII for char 'a'
STORE 67 ; Store to local 'flags'
L7:
L5:
L2:
LOAD_ARG 0 ; 'this' for assignment to member 'fd'
LOAD 65  ; Load parameter 'filename'
LOAD 67  ; Load local var flags
SYS_CALL OPEN ; open
PUTFIELD 0
LOAD_ARG 0 ; Load 'this' to access member 'fd'
GETFIELD 0
PUSH 0
ICMP_LT
JNZ L8
JMP L9
L8:
LOAD_ARG 0 ; 'this' for assignment to member 'isOpen'
PUSH 0
PUTFIELD 1
PUSH 1
INEG
RET
L9:
LOAD_ARG 0 ; 'this' for assignment to member 'isOpen'
PUSH 1
PUTFIELD 1
PUSH 0
RET
.endmethod

.method FileHandler.fclose
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'isOpen'
GETFIELD 1
PUSH 1
ICMP_EQ
JNZ L10
JMP L11
L10:
LOAD_ARG 0 ; Load 'this' to access member 'fd'
GETFIELD 0
SYS_CALL CLOSE ; close
POP
LOAD_ARG 0 ; 'this' for assignment to member 'fd'
PUSH 1
INEG
PUTFIELD 0
LOAD_ARG 0 ; 'this' for assignment to member 'isOpen'
PUSH 0
PUTFIELD 1
L11:
RET
.endmethod

.method FileHandler.fread@[C@I
.limit stack 4
.limit locals 71
LOAD_ARG 0 ; Copy arg 'buffer' to local
STORE 68
LOAD_ARG 1 ; Copy arg 'size' to local
STORE 69
LOAD_ARG 0 ; Load 'this' to access member 'isOpen'
GETFIELD 1
PUSH 0
ICMP_EQ
JNZ L12
JMP L13
L12:
PUSH 1
INEG
RET
L13:
LOAD 68  ; Load parameter 'buffer'
LOAD 69  ; Load parameter 'size'
LOAD_ARG 0 ; Load 'this' to access member 'fd'
GETFIELD 0
SYS_CALL READ ; read
STORE 70 ; Init bytesRead
LOAD 70  ; Load local var bytesRead
RET
.endmethod

.method FileHandler.fwrite@[C@I
.limit stack 4
.limit locals 74
LOAD_ARG 0 ; Copy arg 'buffer' to local
STORE 71
LOAD_ARG 1 ; Copy arg 'size' to local
STORE 72
LOAD_ARG 0 ; Load 'this' to access member 'isOpen'
GETFIELD 1
PUSH 0
ICMP_EQ
JNZ L14
JMP L15
L14:
PUSH 1
INEG
RET
L15:
LOAD 71  ; Load parameter 'buffer'
LOAD 72  ; Load parameter 'size'
LOAD_ARG 0 ; Load 'this' to access member 'fd'
GETFIELD 0
SYS_CALL WRITE ; write
STORE 73 ; Init bytesWritten
LOAD 73  ; Load local var bytesWritten
RET
.endmethod

.method FileHandler.is_open
.limit stack 4
.limit locals 0
LOAD_ARG 0 ; Load 'this' to access member 'isOpen'
GETFIELD 1
RET
.endmethod
