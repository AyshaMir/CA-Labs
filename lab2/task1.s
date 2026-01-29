.text
.globl main
main:
#assuming i and k in x22 and x24, and the base address of Save in x25
Loop: slli x10, x22, 3      # Temp reg x10 = i * 8
      add  x10, x10, x25    # x10 = address of save[i]
      ld   x9, 0(x10)       # Temp reg x9 = save[i]
      bne  x9, x24, Exit   # go to Exit if save[i] != k
      addi x22, x22, 1     # i = i + 1
      beq  x0, x0, Loop   # go to Loop
Exit:


#listing 3
# main:
#     bne x23, x23, Else
#     add x19, x20, x21
#     beq x0, x0, Exit
# Else:
#       sub x19, x20, x21
# Exit:
