big_modinv:
    pop {r10}   // pop size of number in bytes minus four
    pop {r7}    // pop inv pointer
    pop {r9}    // pops v value
    pop {r8}    // pops u value

    push {lr}   // store link register

    ldr r0, =var_u1
    ldr r1, =var_u3
    ldr r2, =var_v1
    ldr r3, =var_v3
    ldr r4, =var_t1
    ldr r5, =var_t3
    ldr r6, =var_q

    push {r10} // preserve r10
    lsl r10, r10, #1
    add r10, r10, #4

    push {r10}
    push {r10}
    push {r0}
    bl big_clear    // clear var_u1
    pop {r10}

    push {r10}
    push {r10}
    push {r1}
    bl big_clear    // clear var_u3
    pop {r10}

    push {r10}
    push {r10}
    push {r2}
    bl big_clear    // clear var_v1
    pop {r10}

    push {r10}
    push {r10}
    push {r3}
    bl big_clear    // clear var_v3
    pop {r10}

    pop {r10} // recover r10

    bl push_all
    push {r8}
    push {r1}
    push {r10}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl resize
    bl pop_all

    bl push_all
    push {r9}
    push {r3}
    push {r10}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl resize
    bl pop_all

    mov r8, r7 // now r8 is the result pointer

    mov r7, #0

    push {r10} // preserve r10
    lsl r10, r10, #1
    add r10, r10, #4
    str r7, [r2, r10] // v1 = 0
    mov r7, #1
    str r7, [r0, r10] // u1 = 1
    pop {r10} // recover r10

modinv_loop:
    push {r10}
    lsl r10, r10, #1
    add r10, r10, #4
    mov r11, r10
    pop {r10}

check_v3_loop:
    cmp r11, #0
    blt exit_modinv_loop
    push {r3}
    ldr r3, [r3, r11]
    cmp r3, #0
    pop {r3}
    sub r11, r11, #4
    beq check_v3_loop

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} 
    push {r4}
    bl big_clear    // clear var_t1
    bl pop_all

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    push {r5}
    bl big_clear    // clear var_t3
    bl pop_all

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    push {r6}
    bl big_clear    // clear var_q
    bl pop_all

    bl push_all
    push {r1}
    push {r3}
    push {r6}
    push {r5}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl big_div
    bl pop_all

    ldr r11, =modinv_temp1
    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} // preserve r12
    push {r11}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    push {r6}
    push {r2}
    push {r11}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl big_mul
    bl pop_all

    ldr r12, =modinv_temp2
    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    push {r12}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    push {r0}
    push {r12}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl resize
    bl pop_all

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    lsl r10, r10, #1
    add r10, r10, #4
    push {r11}
    push {r12}
    push {r11}
    push {r10}
    bl big_add
    bl pop_all

    bl push_all
    push {r11}
    push {r4}
    lsl r10, r10, #1
    add r10, r10, #4
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    sub r10, r10, #4
    lsr r10, r10, #1
    push {r10}
    bl resize
    bl pop_all

    // u1 = v1
    bl push_all
    push {r2}
    push {r0}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    push {r10}
    bl resize
    bl pop_all

    // v1 = t1
    bl push_all
    push {r4}
    push {r2}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    push {r10}
    bl resize
    bl pop_all

    // u3 = v3 
    bl push_all
    push {r3}
    push {r1}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    push {r10}
    bl resize
    bl pop_all

    // v3 = t3
    bl push_all
    push {r5}
    push {r3}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    push {r10}
    bl resize
    bl pop_all

    rsb r7, r7, #0

    b modinv_loop

exit_modinv_loop:
    mov r11, #0
check_u3_loop:
    push {r10}
    lsl r10, r10, #1
    add r10, r10, #4
    cmp r11, r10
    pop {r10}
    beq check_u3_last
    push {r1}
    ldr r1, [r1, r11]
    cmp r1, #0
    pop {r1}
    add r11, r11, #4
    beq check_u3_loop
    b end
check_u3_last:
    ldr r1, [r1, r11]
    cmp r1, #1
    bne end

    cmp r7, #0
    bgt pos_inv

    ldr r7, =var_q
    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} 
    push {r7}
    bl big_clear    // clear var_t1
    bl pop_all

    bl push_all
    push {r9}
    push {r7}
    push {r10}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl resize
    bl pop_all

    bl push_all
    push {r7}
    push {r0}
    push {r8}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl big_sub
    bl pop_all

    b end

pos_inv:
    
    bl push_all
    push {r0}
    push {r8}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    push {r10}
    bl resize
    bl pop_all
    b end
