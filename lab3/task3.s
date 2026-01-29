#array x10, 0x100
#k = x11
#temp = x12, x13, x14
.text
.globl main
main:
    li x10, 0x100   # base address of array v   
    li x2, 12
    sw x2, 0(x10)       # v[0] = 12
    li x2, 15
    sw x2, 4(x10)       # v[1] = 15
    li x11, 0       # k = 0
    jal x1, swap      # call swap function
    li x10, 1         # exit code 1
    ecall
    j Exit

swap:  
    slli x12, x11, 2 # temp = k * 4 (word size)
    add x12, x10, x12 # temp = &v[k]
    lw x13, 0(x12)    # load v[k] into x13
    lw x14, 4(x12)    # load v[k+1] into x14
    sw x14, 0(x12)    # store v[k+1] into v[k]
    sw x13, 4(x12)    # store v[k] into v[k+1]
    jalr x0, 0(x1)    # return
Exit:

