.text
.globl main
main:
    li x10, 0x100    #x
    li x11, 0x200    #y
    li x19, 0        #i=0

    #y = ['m','i','l','o'] 
    li x6, 'm'
    sb x6, 0(x11)
    li, x6, 'i'
    sb x6, 4(x11)
    li x6, 'l'
    sb x6, 8(x11)
    li x6, 'o'
    sb x6, 12(x11)

    addi sp, sp, -12     #3 regs each of 4 bytes
    sw x11, 8(sp)        
    sw x10, 4(sp)        
    sw x19, 0(sp)        

loop:
    lb x17, 0(x11)       #loading y[i] into x17
    sb x17, 0(x10)       #(x[i]=y[i])
    beq x17, x0, exit   #if x17 is null terminator, exit
    addi x10, x10, 4     #next element 
    addi x11, x11, 4     #next element
    addi x19, x19, 1     #i=i+1
    j loop               #jump to loop

exit:
    lw x11, 8(sp)        #restore x11
    lw x10, 4(sp)        #restore x10
    lw x19, 0(sp)        #restore x19
    addi sp, sp, 12      #deallocate stack space