.section BIG_MUL ,"awx" ,%progbits
mul_temp:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0        // temp number
big_mul:
    pop {r10}   // recovers number size in bytes minus four
    pop {r4}     // recovers result pointer
    pop {r5}     // recovers second operand pointer
    pop {r6}     // recovers first operand pointer

    push {lr}   // stores link register

    cmp r10, #0         // check if byte_size <= 0
    blt end             // end if byte_size <= 0

    mov r9, r10     // r0 will be i
    lsl r8, r10, #1
    add r8, r8, #8
    push {r8}  

big_mul_loop_i:
    mov r11, r10
    pop {r8}
    sub r8, #4
    push {r8}
    lsl r7, r10, #1
    add r7, r7, #4

big_mul_loop_j:
    push {r10}
    push {r11}
    push {r7}        // size of temp1
    ldr r7, =mul_temp   // pivot register
    push {r7}
    bl big_clear
    pop {r11}
    pop {r10}

    ldr r0, [r5, r9]    // second_operand[i]
    ldr r1, [r6, r11]   // first_operand[j]  
    umull r2, r3, r0, r1    // singn multiply long r0, r1. Hi : r3, Lo : r2
    str r2, [r7, r8]    // store lower bites of mul
    sub r8, r8, #4    // j--
    str r3, [r7, r8]    // store higher bites of mul

    push {r11}
    push {r10}
    push {r4}
    push {r7}
    push {r4}
    mov r7, r10
    lsl r7, r7, #1
    add r7, r7, #4
    push {r7}
    bl big_add
    pop {r10}
    pop {r11}

    sub r11, r11, #4
    cmp r11, #0
    bge big_mul_loop_j

    cmp r9, #0
    subgt r9, r9, #4
    bgt big_mul_loop_i
    
    pop {r8}

    b end
