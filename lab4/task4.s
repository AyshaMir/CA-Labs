.text
.globl main

# void reverse(char *str, int left, int right) {
#     if (left >= right)
#         return;

#     swap(str[left], str[right]);
#     reverse(str, left + 1, right - 1);
# }

main:
    li x10, 0x100      # base address
    li x5, 'H'
    sb x5, 0(x10)
    li x5, 'E'
    sb x5, 4(x10)
    li x5, 'L'
    sb x5, 8(x10)
    li x5, 'L'
    sb x5, 12(x10)
    li x5, 'O'
    sb x5, 16(x10)

    li x11, 0          # left index
    li x12, 4          # right index (length-1)

    jal x1, reverse    # call recursive function

    li x17, 10         # exit
    ecall

# reverse(x10=base, x11=left, x12=right)
reverse:

    # Base case: if left >= right return
    bge x11, x12, done
    #stack
    addi sp, sp, -12
    sw x1, 8(sp)       # save return address
    sw x11, 4(sp)      # save left
    sw x12, 0(sp)      # save right
    
    #addres str[left] and str[right]
    slli x13, x11, 2 # x13 = left*4
    add x5, x10, x13 # x5 = &str[left]
    lb x6, 0(x5)     # x6 = str[left]   

    #address of str[right]
    slli x14, x12, 2 # x14 = right*4
    add x7, x10, x14 # x7 = &str[right]
    lb x8, 0(x7)     # x8 = str[right]

    # Swap
    sb x8, 0(x5)
    sb x6, 0(x7)

    #recursive call
    addi x11, x11, 1
    addi x12, x12, -1

    jal x1, reverse

    lw x1, 8(sp)
    lw x11, 4(sp)
    lw x12, 0(sp)
    addi sp, sp, 12

done:
    jr x1
