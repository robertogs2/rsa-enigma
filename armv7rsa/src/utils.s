end:
    pop {lr}
    mov pc, lr

// Takes int status as input in r0
exit:
    mov r7, #1
    svc #0

// Clears an big number
big_clear:
    pop {r10}   // recover number pointer
    pop {r11}   // recover number size in bytes minus four
    push {lr}

big_clear_loop:
    cmp r11, #0
    blt end
    
    mov r12, #0
    str r12, [r10, r11]
    
    sub r11, r11, #4
    b big_clear_loop

// Resizes one big number to another, given the pointer to the big numbers and sizes
resize:
    pop {r11} // recovers required size
    pop {r10} // recovers original size
    pop {r8} //pointer to result data
    pop {r9}  // pointer to origin data

    push {lr}

    mov r1, r10

    cmp r10, r11
    movgt r1, r11

resize_loop:
    cmp r1, #0
    blt end

    ldr r0, [r9, r10]
    str r0, [r8, r11]

    sub r10, r10, #1
    sub r11, r11, #1
    sub r1, r1, #1

    b resize_loop

// Push every register
push_all:
    push {r12}
    push {r11}
    push {r10}
    push {r9}
    push {r8}
    push {r7}
    push {r6}
    push {r5}
    push {r4}
    push {r3}
    push {r2}
    push {r1}
    push {r0}

    mov pc, lr

// Pops every register
pop_all:
    pop {r0}
    pop {r1}
    pop {r2}
    pop {r3}
    pop {r4}
    pop {r5}
    pop {r6}
    pop {r7}
    pop {r8}
    pop {r9}
    pop {r10}
    pop {r11}
    pop {r12}

    mov pc, lr
    
// Compares big numbers
big_cmp:
    pop {r10} // pops size in bytes minus four
    pop {r5} // pops second number
    pop {r4} // pops first number

    push {lr}

    mov r2, #0
big_cmp_loop:
    ldr r0, [r4, r2]
    ldr r1, [r5, r2]
    cmp r0, r1
    bne end

    cmp r2, r10
    beq end
    
    add r2, r2, #4
    b big_cmp_loop

// Compares big number against 32bit constant
big_cmp_const:
    pop {r10} // pops size in bytes minus four
    pop {r5} // pops constant
    pop {r4} // pops big number

    push {lr}

    ldr r0, [r4, r10]
    cmp r5, r0
    bne end

    sub r10, r10, #4
big_cmp_const_loop:
    ldr r0, [r4, r10]
    cmp r0, #0
    bne end

    cmp r10, #0
    beq end
    
    sub r10, r10, #4
    b big_cmp_const_loop
// Computes the number of not null elements of a big number
big_length:
    pop {r10}   // array size in bytes minus 1
    pop {r9}    // array ptr

    push {lr} // preserve lr

    mov r0, #0 // j
big_length_loop:
    ldr r1, [r9, r0] // array[j]
    cmp r1, #0 // array[j] != 0 ?
    subne r0, r10, r0 // if(array[j] 1= 0)r0 = array size - j
    bne end
    cmp r0, r10 // j == array size ?
    movge r0, #0 // if(j >= array size)r0 = 0
    bge end
    add r0, r0, #4 // j++
    b big_length_loop

// Rebases big number from 32bit to 16bit
big_rebase_16:
    pop {r10} // array size in bytes minus one 
    pop {r9} // rebased array ptr
    pop {r8} // original array ptr

    push {lr}

    lsl r7, r10, #1 // array size * 2
    add r7, r7, #4 // due to its byte addresability
big_rebase_16_loop:
    ldr r0, [r8, r10] //r0 = array[r10]
    lsr r1, r0, #16 // r1 = array[31:16]
    lsl r0, r0, #16 // r1[31:16] = array[15:0]
    lsr r0, r0, #16 // r1[15:0] = array[15:0]
    str r0, [r9, r7]
    sub r7, r7, #4
    str r1, [r9, r7]
    sub r7, r7, #4
    
    cmp r10, #0
    beq end // while (r10 >= 0)  big_rebase_16_loop
    sub r10, r10, #4 // r10--
    b big_rebase_16_loop

// Rebases big number from 16bit to 32bit
big_rebase_32:
    pop {r10} // array size in bytes minus one 
    pop {r9} // rebased array ptr
    pop {r8} // original array ptr

    push {lr}

    sub r7, r10, #4 // due to its byte addresability
    lsr r7, r7, #1 // array size / 2
big_rebase_32_loop:
    ldr r0, [r8, r10] // r0 = array[r10]
    sub r10, r10, #4 // r10--
    ldr r1, [r8, r10] // r0 = array[r10]
    lsl r1, r1, #16 // r1[31:16] = r1[15:0]
    add r0, r0, r1 // r0 = r1[31:16] + r0[15:0]
    str r0, [r9, r7] // rebased array[r7] = r1[31:16] + r0[15:0]
    sub r10, r10, #4 // r10 --

    cmp r7, #0
    beq end // while (r7 >= 0)  big_rebase_32_loop
    sub r7, r7, #4 // r7--
    b big_rebase_32_loop
