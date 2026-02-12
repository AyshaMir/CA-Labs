.data
str: .asciiz "HELLO"

.text
.globl main

# -----------------
# MAIN
# -----------------
main:
    la a0, str          # a0 = address of string
    li a1, 0            # left = 0
    li a2, 4            # right = length-1 (HELLO = 5 chars)

    jal ra, reverse

    # print reversed string
    la a0, str
    li a7, 4
    ecall

    li a7, 10
    ecall


# -----------------
# reverse(str, left, right)
# a0 = str
# a1 = left
# a2 = right
# -----------------
reverse:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a1, 8(sp)
    sw a2, 4(sp)

    bge a1, a2, rev_done

    # address of str[left]
    add t0, a0, a1
    lb t1, 0(t0)

    # address of str[right]
    add t2, a0, a2
    lb t3, 0(t2)

    # swap
    sb t3, 0(t0)
    sb t1, 0(t2)

    addi a1, a1, 1
    addi a2, a2, -1

    jal ra, reverse

rev_done:
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra
