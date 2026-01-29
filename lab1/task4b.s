.text
.globl main 
main:
    li x10, 0x100
    li x11, 0x200
    li x12, 0x300

    #array a
    li t0, 1
    sb t0, 0(x10)       
    li t0, 2
    sb t0, 1(x10)
    li t0, 3
    sb t0, 2(x10)
    li t0, 4
    sb t0, 3(x10)       

    #array b
    li t1, 10
    sb t1, 0(x11)
    li t1, 20
    sb t1, 2(x11)
    li t1, 30
    sb t1, 4(x11)
    li t1, 40
    sb t1, 6(x11)       

    #array c = a + b
    lb x9, 0(x10)
    lh x8, 0(x11)
    add x7, x9, x8
    sw x7, 0(x12)

    lb x9, 1(x10)
    lh x8, 2(x11)
    add x7, x9, x8
    sw x7, 4(x12)

    lb x9, 2(x10)
    lh x8, 4(x11)
    add x7, x9, x8
    sw x7, 8(x12)

    lb x9, 3(x10)
    lh x8, 6(x11)
    add x7, x9, x8
    sw x7, 12(x12)
end:
    j end
