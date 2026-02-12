
.text
.globl main
main:
    li x5, 1 
    li x6, 5 #n
    li x3, 1 #i
    li x4, 1 #result
    blt x6, x5, exit
loop:
    bgt x3, x6,exit #if i>n exit
    mul x4, x4, x3
    addi x3, x3, 1 #i++
    j loop 

exit:
    j exit