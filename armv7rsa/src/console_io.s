/* Erternal */
.global printf
print:
    pop {r10}   // retrieve the number size in bytes minus four
    pop {r4}    // address of number to print
    push {lr}   // store lr value

    mov r11, #0
print_loop:
    cmp r11, r10
    bgt end

    adr r0, fmt1   // if not las word, %d
    adreq r0, fmt2 // if last word, %d\n
    
    ldr r1, [r4, r11]      // word to print

    bl printf   // call printf

    add r11, r11, #4

    b print_loop

print_reg:
    push {lr}
    adr r0, fmt2         // seed printf
    BL printf
    b end

fmt1:
        .asciz "%08X,"
fmt2:
        .asciz "%08X\n"
