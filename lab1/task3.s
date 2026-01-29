.text
.globl main
main:
    li x20, 5 #a
    li x1, 5 #temp
    add x21, x0, x0 #b+0
    #x22 d x23 e

    addi x20, x21, 32  #a= +32
   #d = a+b -5
    add x22, x20, x21 
    sub x22, x22, x1

   #e = (((a-d) + (b-a)) +d)
    sub x5, x20, x22#a-d
    sub x6, x21, x20#b-a
    add x7, x5, x6#(a-d)+(b-a)
    add x23, x7, x22#e

   #e = a+b+d+e
    add x23, x23, x20
    add x23, x23, x21
    add x23, x23, x22

end:
    j end