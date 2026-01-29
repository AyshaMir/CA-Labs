.text
.globl main
main: #x20=x, x21=a, x22=b, x23=c
    li x22, 10 #b=5
    li x23, 5 #c=10
    li x20, 4 #x=4

    #case 1
    li x1, 1
    beq x20, x1, Case1

    #case 2
    li x1, 2
    beq x20, x1, Case2

    #case 3
    li x1, 3
    beq x20, x1, Case3
    
    #case 4
    li x1, 4
    beq x20, x1, Case4

    j default_case

Case1:
    add x21, x22, x23 #a=b+c
    j end_case

Case2:
    sub x21, x22, x23 #a=b-c
    j end_case

Case3:
    slli x21, x22, 1 #a=b*2
    j end_case

Case4:
    srai x21, x22, 1 #a=b/2
    j end_case

default_case:
    li x21, 0 #default case: a=0
end_case:
    j end

end:

