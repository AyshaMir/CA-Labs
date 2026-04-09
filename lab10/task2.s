.data
.text
.globl _start

_start:
    li x4, 256          # x4 = LED address
    li x5, 512          # x5 = switch address
    li x6, 124          # x6 = reset address

idle_state:
    lw x7, 0(x5)            # read switch value
    beq x7, x0, idle_state   # if switch value is 0, keep waiting

    add x10, x7, x0         # pass switch value in x10
    jal x1, countdown       # call countdown subroutine
    j idle_state             # after countdown ends, return to waiting state

countdown:
    addi x2, x2, -16        # make space on stack
    sw x1, 12(x2)           # save return address
    sw x8, 8(x2)            # save x8
    sw x9, 4(x2)            # save x9, reset value
    sw x18, 0(x2)           # save x18

    add x8, x10, x0         # x8 = current countdown value

countdown_loop:
    lw x9, 0(x6)                # read reset value
    bne x9, x0, countdown_reset # if reset pressed, reset immediately

    sw x8, 0(x4)                # display current value on LEDs

    addi x8, x8, -1             # decrement count
    blt x8, x0, countdown_done  # if value < 0, stop

    li x18, 10000000            # delay counter

delay_loop:
    addi x18, x18, -1
    bne x18, x0, delay_loop
    j countdown_loop

countdown_reset:
    sw x0, 0(x4)                # clear LEDs
    j countdown_done

countdown_done:
    lw x1, 12(x2)           # restore return address
    lw x8, 8(x2)            # restore x8
    lw x9, 4(x2)            # restore x9
    lw x18, 0(x2)           # restore x18
    addi x2, x2, 16         # free stack space
    jalr x0, 0(x1)          # return