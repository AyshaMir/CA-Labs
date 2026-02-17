.text
.globl main

main:
    li x10, 5          # n = 5
    jal x1, ntri       # call ntri(5)
    j exit

# int ntri(int n)
# if (n <= 1) return 1;
# return n + ntri(n-1);
ntri:
    addi sp, sp, -16
    sw x1, 8(sp)       # save return address
    sw x10, 0(sp)          # save original n

    li x5, 1
    ble x10, x5, base_case # if (n <= 1)
    addi x10, x10, -1      # n = n - 1
    jal x1, ntri        # recursive call
    addi x6, x10, 0
    lw x10, 0(sp)        # restore original n
    add x10, x10, x6   

    lw x1, 8(sp)         # restore return address
    addi sp, sp, 16        # deallocate stack
    jalr x0, 0(x1)     

base_case:
    li x10, 1              # return 1
    lw x1, 8(sp)     # restore return address
    addi sp, sp, 16        # deallocate stack
    jalr x0, 0(x1)         


exit:
