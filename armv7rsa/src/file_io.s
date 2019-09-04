// https://w3challs.com/syscalls/?arch=arm_strong
readfile:
    pop {r4}    // pop destination pointer
    pop {r0}    // pop file name

    push {lr}   // store link register

    @ Open an input file for reading
    mov r1,#0 
    ldr r2,=0666            @ permissions
    mov r7,#5
    svc 0 
    cmp r0, #0
    blt exit

    @ Save the file handle in memory:
    ldr r1,=Handle     @  load input file handle
    str r0,[r1]              @  save the file handle

    ldr r2, =size
    ldr r2, [r2]
    lsr r2, r2, #3
    //sub r2, r2, #1
    // Read file data into readBuffer
    ldr r0,=Handle           @ load input file handle
    ldr r0,[r0]
    ldr r1,=readBuffer
    mov r7, #3  // read syscall
    svc 0                    @ read the integer into R0

    mov r0, r1
    sub r3, r2, #4
    mov r5, #0
next_char:
    cmp r2, #0
    blt done_reading
    ldr r1, [r0, r2]
    cmp r1, #0
    sub r2, r2, #1
    beq next_char

    mov r6, #8
    mul r6, r5, r6
    lsl r1, r1, #24
    lsr r1, r1, r6
    add r5, r5, #1
    cmp r5, #4
    moveq r5, #0

    ldr r6, [r4, r3]

    add r1, r6, r1
    str r1, [r4, r3]

    subeq r3, r3, #4

    b next_char
done_reading:
    ldr r0, =Handle
    ldr r0, [r0]
    mov r7, #118 //fsync syscall
    svc #0

    //close syscall
    mov r7, #6      // 6 is close
    svc #0

    b end

writefile:
    pop {r0}    // pop file name
    pop {r4}    // pop data to write

    push {lr}
    //open syscall 
    mov r1, #0101 // O_WRONLY | O_CREAT
    ldr r2, =0666 // permissions
    mov r7, #5 // 5 is system call number for open
    svc #0
    cmp r0, #0
    blt exit

    //r0 contains fd (file descriptor, an integer)
    mov r5, r0

    //write syscall
    //use stack as buffer
    mov r1, r4
    ldr r2, =size
    ldr r2, [r2]
    lsr r2, r2, #3
    mov r7, #4      // 4 is write
    svc #0

    //fsync syscall
    mov r0, r5
    mov r7, #118
    svc #0

    //close syscall
    mov r7, #6      // 6 is close
    svc #0

    b end
