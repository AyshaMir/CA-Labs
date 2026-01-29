.text
.globl main

main:
    li x22, 0      # i = 0
    li x23, 0      # sum = 0
    li x24, 0x200  # base address of array a
    li x27, 10     # limit = 10

loop1:
    bge x22, x27, reset
    slli x25, x22, 2      # x25 = i * 4
    add  x25, x25, x24 
    sw   x22, 0(x25)     # a[i] = i
    addi x22, x22, 1
    j loop1

reset:
    li x22, 0      # reset i for second loop

loop2:
    bge x22, x27, end
    slli x25, x22, 2      # x25 = i * 4
    add  x25, x25, x24
    lw   x26, 0(x25)     # x26 = a[i]
    add  x23, x23, x26  # sum += a[i]
    addi x22, x22, 1
    j loop2

end:
