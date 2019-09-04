/* Erternal */
.include "console_io.s"
.include "addition.s"
.include "substraction.s"
.include "multiplication.s" 
.include "division.s"
.include "exp_mod.s"
.include "mod_inv.s"
.include "gcd.s"
.include "coprime.s"
.include "encoder.s"
.include "decoder.s"
.include "utils.s"
.include "file_io.s"
.include "mem_vars.s"

.text
.globl main

main:
    // Read command line args
    ldr r1, [r1, #4]
    ldr r1, [r1]
    lsl r1, r1, #16
    lsr r1, r1, #24

    push {r1}

    // Computing n, the modulus of the algorithm.
    ldr r0, =P // pointer to p
    push {r0}
    ldr r0, =Q // pointer to q
    push {r0}
    ldr r0, =n // pointer to n
    push {r0}
    ldr r0, =size // key size ptr
    ldr r0, [r0] // key size in bits
    lsr r0, r0, #6 // size / 2
    sub r0, r0, #1
    lsl r0, r0, #2
    push {r0}
    bl big_mul

    pop {r1}
    cmp r1, #0x65
    bne try_to_decode

    // Computing P-1
    ldr r0, =P
    push {r0}
    ldr r0, =rsa_temp
    push {r0}
    ldr r0, =P
    push {r0}
    ldr r0, =size // key size ptr
    ldr r0, [r0] // key size in bits
    lsr r0, r0, #6 // size / 2
    sub r0, r0, #1
    lsl r0, r0, #2
    push {r0}
    bl big_sub

    // Computing Q-1
    ldr r0, =Q
    push {r0}
    ldr r0, =rsa_temp
    push {r0}
    ldr r0, =Q
    push {r0}
    ldr r0, =size // key size ptr
    ldr r0, [r0] // key size in bits
    lsr r0, r0, #6 // size / 2
    sub r0, r0, #1
    lsl r0, r0, #2
    push {r0}
    bl big_sub

    // Computing l = (Q-1)*(P-1)
    ldr r0, =P // pointer to p
    push {r0}
    ldr r0, =Q // pointer to q
    push {r0}
    ldr r0, =l // pointer to l
    push {r0}
    ldr r0, =size // key size ptr
    ldr r0, [r0] // key size in bits
    lsr r0, r0, #6 // size / 2
    sub r0, r0, #1
    lsl r0, r0, #2
    push {r0}
    bl big_mul

    // Compute encryption key
    bl compute_e

    //ldr r0, =e
    //push {r0}
    //mov r0, #12
    //push {r0}
    //bl print

    // Compute decryption key
    bl compute_d
    //ldr r0, =d
    //push {r0}
    //mov r0, #12
    //push {r0}
    //bl print
    
    ldr r0, =filename
    push {r0}
    ldr r0, =msg
    push {r0}
    bl readfile

    //bl push_all
    //ldr r0, =msg
    //push {r0}
    //mov r0, #12
    //push {r0}
    //bl print
    //bl pop_all
    

    bl encode 

    //bl push_all
    //ldr r0, =num3
    //push {r0}
    //mov r0, #12
    //push {r0}
    //bl print
    //bl pop_all


    ldr r0, =num3
    push {r0}
    ldr r0, =output_file
    push {r0}
    bl writefile

    ldr r0, =d
    push {r0}
    ldr r0, =decryption_key
    push {r0}
    bl writefile

try_to_decode:
    cmp r1, #0x64
    bne finish

    ldr r0, =decryption_key
    push {r0}
    ldr r0, =d
    push {r0}
    bl readfile

    //ldr r0, =d
    //push {r0}
    //mov r0, #12
    //push {r0}
    //bl print

    ldr r0, =output_file
    push {r0}
    ldr r0, =msg
    push {r0}
    bl readfile

    bl decode

    //ldr r0, =num3
    //push {r0}
    //mov r0, #12
    //push {r0}
    //bl print

    ldr r0, =num3
    push {r0}
    ldr r0, =output_file
    push {r0}
    bl writefile


finish:
    mov r0, #0
    b exit
