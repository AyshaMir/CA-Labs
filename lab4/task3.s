.text
.globl main

main:
    li x10, 0x100 #a

    li x5, 23
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
    li x5, 0 #i
outer_loop:
    bge x5, x11, exit
    # li x6, 0 #j
    addi x6, x5, 0 #j=i
inner_loop:
    bge x6, x11, next

    slli x7, x5, 2 #x7 = i*4
    add x7, x10, x7 #x7 = &a[i]
    slli x8, x6, 2 #x8 = j*4
    add x8, x10, x8 #x8 = &a[j]

    lw x9, 0(x7) #x9 = a[i]
    lw x12, 0(x8) #x12 = a[j]

    bge x9, x12, no_swap
    add x13, x9, x0 #x13 = a[i]
    sw x12, 0(x7) #a[i] = a[j]
    sw x13, 0(x8) #a[j] = a[i]

no_swap:
    addi x6, x6, 1 #j++
    j inner_loop

next:
    addi x5, x5, 1 #i++
    j outer_loop
exit:
    jr x1