.section BIG_ADD ,"ax" ,%progbits
big_add:
    pop {r10}    // recovers number size in bytes minus four
    pop {r4}     // recovers result pointer
    pop {r1}     // recovers second operand pointer
    pop {r0}     // recovers first operand pointer

    push {lr}   // store link register

    cmp r10, #0         // check if byte_size <= 0
    blt end             // end if byte_size <= 0

    // performs addition with the 32 less significant bits of the two operands
    ldr r2, [r0,r10]
    ldr r3, [r1,r10]
    adds r2, r2, r3
    str r2, [r4,r10]
    sub r10, r10, #4    // next number word

    mov r11, #0
    adc r11, r11, #0

big_add_loop:
    cmp r10, #0
    blt end             // end if byte_size <= 0
    // performs addition with the next 32 bits and carry

    mov r2, #0xffffffff
    adds r2, r11

    ldr r2, [r0,r10]
    ldr r3, [r1,r10]
    adcs r2, r2, r3
    str r2, [r4,r10]

    mov r11, #0
    adc r11, r11, #0

    sub r10, r10, #4    // next word

    b big_add_loop      // loop addition
    