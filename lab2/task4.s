.text
.globl main

main:
    li x5, 3        # a
    li x6, 3        # b
    li x7, 0        # i
    li x10, 0x100   # base address

outerloop:
    bge x7, x5, end
    li x29, 0       # j
    beq x0, x0, innerloop

innerloop:
    bge x29, x6, next
    li x11, 4
    mul x11, x11, x29
    add x11, x11, x10
    add x12, x7, x29     # x12 = i + j
    sw x12, 0(x11)       # D[j*4] = i + j
    addi x29, x29, 1
    beq x0, x0, innerloop

next:
    addi x7, x7, 1       # i++
    beq x0, x0, outerloop
end:
    j end