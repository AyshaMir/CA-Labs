.text
.globl main

main:
    li x10, 0x100 #a

    li x5, 2 
    sw x5, 0(x10)
    li x5, 4
    sw x5, 4(x10)
    li x5, 9
    sw x5, 8(x10)
    li x5, 16
    sw x5, 12(x10)
    li x5, 19
    sw x5, 16(x10)

    li x11, 5# len
    jal x1, bubble_sort #call sum function

    li x17, 10
    ecall

bubble_sort:
    beq x10, x0, exit
    beq x11, x0, exit
    li t0, 0 #i
outer_loop:
    bge t0, x11, exit
    # li t1, 0 #j
    addi t1, t0, 0 #j=i
inner_loop:
    bge t1, x11, next

    slli t2, t0, 2 #t2 = i*4
    add t2, x10, t2 #t2 = &a[i]
    lw t3, 0(t2) #t3 = a[i]

    slli t4, t1, 2 #t4 = j*4
    add t4, x10, t4 #t4 = &a[j]
    lw t5, 0(t4) #t5 = a[j]

    bge t3, t5, no_swap

    sw t5, 0(t2) #a[i] = a[j]
    sw t3, 0(t4) #a[j] = a[i]

no_swap:
    addi t1, t1, 1 #j++
    j inner_loop

next:
    addi t0, t0, 1 #i++
    j outer_loop
exit:
    jr x1