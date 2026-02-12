.text
.globl main

main:
li x10, 5 #num =5
jal x1, ntri 
addi x11, x10,0
li x10,1
ecall
j exit

ntri:
#allocation of stack
addi sp, sp, -16
sw x1, 8(sp)
sw x10, 0(sp)
addi x5, x10, -1
blt x10, x0, base_case 

Loop:
addi x10, x10, -1
jal x1, ntri #recursive call with n-1
addi x6, x10, 0
lw x10, 0(sp) #pop the stack 
lw x1, 8(sp)
addi sp, sp, 16
add x10, x10, x6
jalr x0, 0(x1)

base_case:
addi x10, x0, 0
addi sp, sp,16
jalr x0,0(x1)

exit: