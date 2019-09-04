// This function does x^k mod n
big_exp_mod:
    pop {r10}   // recovers number size in bytes minus four
    pop {r7}    // recovers result pointer
    pop {r6}    // pops modulus ptr, n
    pop {r5}    // recovers power ptr, k
    pop {r4}    // recovers x pointer

    push {lr}

    cmp r10, #0         // check if byte_size <= 0
    blt end             // end if byte_size <= 0

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    ldr r6, =expmod_temp3
    push {r10} // preserve r12
    push {r6}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    push {r6}
    ldr r6, =expmod_temp3
    push {r6}
    push {r10}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl resize
    bl pop_all
    ldr r6, =expmod_temp3

    mov r0, #1
    str r0, [r7, r10]

    mov r11, #0
    ldr r8, =expmod_temp1
    ldr r9, =expmod_temp2
    ldr r0, =expmod_temp4
big_exp_mod_loop:
    cmp r11, r10
    bgt end

    mov r1, #31
big_exp_mod_loop1:
    cmp r1, #0
    addlt r11, r11, #4
    blt big_exp_mod_loop

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} // preserve r12
    push {r8}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} // preserve r12
    push {r9}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} // preserve r12
    push {r0}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    push {r7}
    push {r7}
    push {r8}
    push {r10}
    bl big_mul
    bl pop_all

    bl push_all
    push {r8}
    push {r6}
    push {r0}
    push {r9}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl big_div
    bl pop_all

    bl push_all
    add r9, r9, r10
    add r9, r9, #4
    push {r9}
    push {r7}
    push {r10}
    push {r10}
    bl resize
    bl pop_all

    ldr r2, [r5, r11]
    mov r3, #31
    sub r3, r3, r1
    lsl r2, r2, r3
    add r3, r3, r1
    lsr r2, r2, r3

    cmp r2, #1
    bne big_exp_mod_skip

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} // preserve r12
    push {r8}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} // preserve r12
    push {r9}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10} // preserve r12
    push {r0}
    bl big_clear    // clear div_temp2
    bl pop_all

    bl push_all
    push {r7}
    push {r4}
    push {r8}
    push {r10}
    bl big_mul
    bl pop_all

    bl push_all
    push {r8}
    push {r6}
    push {r0}
    push {r9}
    lsl r10, r10, #1
    add r10, r10, #4
    push {r10}
    bl big_div
    bl pop_all

    bl push_all
    add r9, r9, r10
    add r9, r9, #4
    push {r9}
    push {r7}
    push {r10}
    push {r10}
    bl resize
    bl pop_all
    
big_exp_mod_skip:
    sub r1, r1, #1
    b big_exp_mod_loop1
    