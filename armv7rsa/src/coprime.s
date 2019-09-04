// If coprime then zero flag will be raised
big_coprime:
    pop {r10}   // operand size in bytes minus four
    pop {r1}    // ptr to second operand
    pop {r0}    // ptr to first operand

    push {lr}   // str link register for return

    bl push_all
    push {r0}
    ldr r0, =gcd_temp1
    push {r0}
    push {r10}
    push {r10}
    bl resize
    bl pop_all
    ldr r0, =gcd_temp1

    bl push_all
    push {r1}
    ldr r1, =gcd_temp2
    push {r1}
    push {r10}
    push {r10}
    bl resize
    bl pop_all
    ldr r1, =gcd_temp2

    push {r0}
    push {r1}
    push {r10}
    bl big_gcd

    ldr r3, [r0, r10]

    cmp r3, #1
    bne end

    sub r10, r10, #4

big_coprime_loop:

    ldr r3, [r0, r10]
    cmp r3, #0
    bne end

    cmp r10, #0
    beq end
    sub r10, r10, #4
    b big_coprime_loop
