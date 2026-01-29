#g = x10
#h = x11
#i = x12
#j = x13
#f = x20
#temp = x18, x19

.text
.globl main
leaf_example:
    li x10, 5          # g = 5
    li x11, 10         # h = 10
    li x12, 15         # i = 15
    li x13, 20         # j = 20

    addi sp, sp, -12
    sw x18, 8(sp)        # save x18
    sw x19, 4(sp)         # save x19
    sw x20, 0(sp)         # save x20

    add x18, x10, x11     # x18 = g + h
    add x19, x12, x13     # x19 = i + j
    sub x20, x18, x19     # f = (g + h) - (i + j)
    addi x11, x20, 0

    lw x18, 8(sp)        # restore x18
    lw x19, 4(sp)        # restore x19
    lw x20, 0(sp)        # restore x20
    addi sp, sp, 12
    li x10, 1              # exit code 1
    ecall
    j Exit
Exit:


