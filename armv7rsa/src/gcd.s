big_gcd:
    pop {r10}   // operand size in bytes minus four
    pop {r1}    // ptr to second operand
    pop {r0}    // ptr to first operand

    push {lr}   // str link register for return

big_gcd_loop:
    bl push_all
    push {r1}
    mov r1, #0
    push {r1}
    push {r10}
    bl big_cmp_const
    bl pop_all

    beq end

    ldr r2, =temp0 // will store division quotient
    ldr r3, =temp1 // will store division remainder

    bl push_all
    push {r10}
    push {r2}
    bl big_clear
    bl pop_all

    bl push_all
    push {r10}
    push {r3}
    bl big_clear
    bl pop_all

    bl push_all
    push {r0}
    push {r1}
    push {r2}
    push {r3}
    push {r10}
    bl big_div
    bl pop_all

    bl push_all
    push {r1}
    push {r0}
    push {r10}
    push {r10}
    bl resize
    bl pop_all

    bl push_all
    push {r3}
    push {r1}
    push {r10}
    push {r10}
    bl resize
    bl pop_all

    b big_gcd_loop

//big_gcd_loop:
    //bl push_all
    //push {r0}
    //push {r1}
    //push {r10}
    //bl big_cmp
    //bl pop_all  
//
    //beq end
//
    //bl push_all
    //push {r0}
    //push {r10}
    //bl print
    //bl pop_all
//
    //bl push_all
    //push {r1}
    //push {r10}
    //bl print
    //bl pop_all
    //b .
//
    //blt less
//
    //bl push_all
    //push {r0}
    //push {r1}
    //push {r0}
    //push {r10}
    //bl big_sub
    //bl pop_all
//
    //b big_gcd_loop
//
//less:
    //bl push_all
    //push {r1}
    //push {r0}
    //push {r1}
    //push {r10}
    //bl big_sub
    //bl pop_all
//
    //b big_gcd_loop

