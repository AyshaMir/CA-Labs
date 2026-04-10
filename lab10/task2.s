.equ led_address,     256
.equ switch_address,  512
.equ reset_address,   124
.equ delay_counter,  10000000

.section .text
.globl _start

_start:
    li x4, led_address  #x4 = LED address
    li x5, switch_address      #x5 = switch address
    li x6, reset_address       #x6 = reset address

    sw x0, 0(x4)            #clear LEDs at start
    

idle_state:
    lw x7, 0(x5)        #x7 = switch value
    beq x7, x0, idle_state  #stay here if switch value is 0

    add x10, x7, x0      #x10 = argument to countdown
    jal x1, countdown     #call countdown
    j idle_state            

countdown:
    addi x2, x2, -16        #make stack space
    sw x1, 12(x2)          #save return address
    sw x8, 8(x2)   #save x8
    sw x9, 4(x2)         #save x9
    sw x18, 0(x2)        #save x18

    add x8, x10, x0       #x8 = current count value

countdown_loop:
    lw x9, 0(x6)            #read reset
    bne x9, x0, countdown_reset
    sw x8, 0(x4)         #display current value on LEDs

    addi x8, x8, -1         #decrement value
    blt x8, x0, countdown_done

    jal x1, delay_1s  #delay before next number
    j countdown_loop

countdown_reset:
    sw x0, 0(x4)            #clear LEDs

countdown_done:
    lw x1, 12(x2)           #restore return address
    lw x8, 8(x2)           #restore x8
    lw x9, 4(x2)      #restore x9
    lw x18, 0(x2)          #restore x18
    addi x2, x2, 16    #free stack space
    jalr x0, 0(x1)         #return

delay_1s:
    addi x2, x2, -8        #save stack space for delay function
    sw x1, 4(x2)     #save return address
    sw x18, 0(x2)           #save x18
    li x18, delay_counter

delay_loop:
    addi x18, x18, -1
    bne x18, x0, delay_loop

    lw x1, 4(x2)            #restore return address
    lw x18, 0(x2)        #restore x18
    addi x2, x2, 8          #free stack space
    jalr x0, 0(x1)       #return