.section BIG_DIV ,"awx" ,%progbits
divisor_16:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
dividend_16:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
reminder_16:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
quotient_16:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

big_div:
    pop {r10}   // array size in bytes minus 1
    pop {r9}    // pop reminder ptr (r)
    pop {r8}    // pop quotient ptr (q)
    pop {r7}    // pop dividend ptr (v)
    pop {r6}    // pop divisor ptr (u)

    push {lr}

    bl push_all
    push {r6}
    adr r6, divisor_16
    push {r6}
    push {r10}
    bl big_rebase_16
    bl pop_all

    bl push_all
    push {r7}
    adr r6, dividend_16
    push {r6}
    push {r10}
    bl big_rebase_16
    bl pop_all

    lsl r10, r10, #1
    add r10, r10, #4

    bl push_all
    push {r10}
    adr r6, quotient_16
    push {r6}
    bl big_clear    // clear quotient_16
    bl pop_all

    bl push_all
    push {r10}
    adr r6, reminder_16
    push {r6}
    bl big_clear    // clear reminder_16
    bl pop_all

    bl push_all
    adr r6, divisor_16
    push {r6}
    adr r6, dividend_16
    push {r6}
    adr r6, quotient_16
    push {r6}
    adr r6, reminder_16
    push {r6}
    push {r10}
    bl divmnu
    bl pop_all  

    bl push_all
    adr r6, reminder_16
    push {r6}
    push {r9}
    push {r10}
    bl big_rebase_32
    bl pop_all

    bl push_all
    adr r6, quotient_16
    push {r6}
    push {r8}
    push {r10}
    bl big_rebase_32
    bl pop_all

    b end

.section DIVMNU ,"awx" ,%progbits
div_temp1:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // temp number
div_d:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0       // temp number
nu:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0       // temp number
nv:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0      // temp number
div_p:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0            // temp number
divBase:
        .word 65536        // temp number
temp_16:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
temp_32:
        .word 0, 0, 0, 0, 0, 0, 0, 0

divmnu:
    pop {r10}   // array size in bytes minus 1
    pop {r9}    // pop reminder ptr (r)
    pop {r8}    // pop quotient ptr (q)
    pop {r7}    // pop dividend ptr (v)
    pop {r6}    // pop divisor ptr (u)

    push {lr}

    adr r1, nu // ptr to nu
    bl push_all
    push {r10}
    push {r1}
    bl big_clear    // clear reminder_16
    bl pop_all

    adr r1, nv // ptr to nu
    bl push_all
    push {r10}
    push {r1}
    bl big_clear    // clear reminder_16
    bl pop_all

    bl push_all
    push {r6} // pass u
    push {r7} // pass v
    push {r10} // pass array size
    bl big_cmp
    bl pop_all

    beq u_eq_v
    bgt u_gt_v

    // u < v
    bl push_all
    push {r6}
    push {r9}
    push {r10} // check if size of reminder is same as divisor 
    push {r10}
    bl resize
    bl pop_all
    b end

u_eq_v:
    mov r0, #1
    str r0, [r8,r10] // check if size of quotient is same as divisor
    b end

u_gt_v:
    bl push_all
    push {r7} // pass v
    push {r10} // pass array size
    bl big_length // n = big_length(v)
    vmov s0, r0 // preserve n
    bl pop_all
    vmov r0, s0 // recover n

    cmp r0, #0 // sizeof(v) == 1? 
    bgt second_case // if(sizeof(v) > 1) -> second_case
    bl push_all
    push {r6} // pass u
    ldr r7, [r7, r10] // v[vecsize-1]
    push {r7} // pas v[vecsize-1]
    push {r8} // pas q 
    add r9, r9, r10 // &r[vecsize-1]
    push {r9} // pass &r[vecsize-1]
    push {r10} // pass array size
    bl big_short_div
    bl pop_all
    b end
second_case:
    sub r1, r10, r0 //array size - n
    ldr r1, [r7, r1] // v[array size - n]
    add r1, r1, #1 // v[array size - n] + 1
    vmov s1, r1 // mov r1 to float register
    vcvt.f32.u32 s1, s1
    adr r1, divBase
    ldr r1, [r1] // divBase value
    vmov s0, r1 // mov divBase to float register
    vcvt.f32.u32 s0, s0
    vdiv.f32 s0, s0, s1 // divBase / (v[array size - n] + 1)
    vcvt.u32.f32 s0, s0
    vmov r1, s0 // mov divBase / (v[array size - n] + 1) to int register
    adr r2, div_d
    str r1, [r2, r10] // div_d  = divBase / (v[array size - n] + 1)
    
    adr r1, nu // ptr to nu

    bl push_all
    push {r6}
    adr r6, temp_32
    push {r6}
    push {r10}
    bl big_rebase_32
    bl pop_all

    // Step 1
    bl push_all
    sub r10, r10, #4
    lsr r10, r10, #1
    adr r6,  temp_32
    push {r6} // pass u
    add r2, r2, r10
    add r2, r2, #4
    push {r2} // pass div_d
    push {r1} // pass nu
    push {r10} // pass array size
    bl big_mul
    bl pop_all

    bl push_all
    push {r1}
    adr r6,  temp_32
    push {r6}
    push {r10}
    sub r10, r10, #4
    lsr r10, r10, #1
    push {r10}
    bl resize 
    bl pop_all

    bl push_all
    adr r6,  temp_32
    push {r6}
    push {r1}
    sub r10, r10, #4
    lsr r10, r10, #1    
    push {r10}
    bl big_rebase_16
    bl pop_all


    bl push_all
    push {r7}
    adr r7, temp_32
    push {r7}
    push {r10}
    bl big_rebase_32
    bl pop_all

    adr r1, nv // ptr to nv
    bl push_all
    sub r10, r10, #4
    lsr r10, r10, #1
    adr r7, temp_32
    push {r7} // pass v
    add r2, r2, r10
    add r2, r2, #4
    push {r2} // pass div_d
    push {r1} // pass nv
    push {r10} // pass array size
    bl big_mul
    bl pop_all

    bl push_all
    push {r1}
    adr r7, temp_32
    push {r7}
    push {r10}
    sub r10, r10, #4
    lsr r10, r10, #1
    push {r10}
    bl resize 
    bl pop_all

    bl push_all
    adr r7, temp_32
    push {r7}
    push {r1}
    sub r10, r10, #4
    lsr r10, r10, #1    
    push {r10}
    bl big_rebase_16
    bl pop_all

    //Step 2
    bl push_all
    push {r6} // pass u
    push {r10} // pass size of array
    bl big_length // m = big_length(u)
    vmov s0, r0 // store m
    bl pop_all
    vmov r1, s0 // recover m

    sub r1, r1, r0 // j = m-n
step3:
    // r0 = n
    // r1 = j
    add r2, r0, #4 // n+1
    add r2, r2, r1 // n+1+j
    sub r2, r10, r2 // array size -1 -(n+1+j)
    adr r4, nu // ptr to nu
    ldr r2, [r4,r2] // u[j+n+1]
    ldr r3, =divBase // ptr to divBase
    ldr r3, [r3] // divBase value

    mul r2, r2, r3 // nu[j+n+1]*divBase
    add r3, r0, r1 // j+n
    sub r3, r10, r3 // array size - (j+n)
    ldr r3, [r4,r3] // nu[size - (j+n)]
    add r2, r2, r3 // e = nu[j+n+1]*divBase + nu[j+n]
    ldr r3, =nv // ptr to nv
    sub r11, r10, r0
    ldr r3, [r3, r11] // f = nv[array size - n]
    // mov e and f to float reisters to divide them
    vmov s0, r2
    vcvt.f32.u32 s0, s0
    vmov s1, r3
    vcvt.f32.u32 s1, s1
    vdiv.f32 s0, s0, s1 // e//f
    // Move the result back to int registers
    vcvt.u32.f32 s0, s0
    vmov r4, s0 // qt = e // v
    mul r3, r3, r4 // qt * f
    sub r3, r2, r3 // rt = e - qt*f

step3_loop:
    ldr r5, =divBase // divBase ptr
    ldr r5, [r5] // divBase value
    cmp r4, r5 // compare(qt, divBase)
    bge step3_aux // if (qt < divBase) --> step4

    bl push_all 
    sub r0, r0, #4 // n-1
    ldr r6, =nv // ptr to nv
    sub r7, r10, r0
    ldr r6, [r6, r7]// nv[array size - (n-1)]
    mul r4, r4, r6 // qt * nv[array size - (n-1)]
    mul r3, r3, r5 // rt*divBase
    add R0, r0, r1 // n-1+j 
    sub r7, r10, r0 // array size - 1 - (n-1+j)
    ldr r6, =nu // ptr to nu
    ldr r6, [r6, r7] //nu[array size - 1 - (n-1+j)]
    add r3, r3, r6 // rt*divBase + nu[array size - 1 - (n-1+j)]

    // This might cause problems because only works for unsigned
    lsr r4, r4, #4 // remove less significant digit
    lsr r3, r3, #4  /// remove less significant digit

    cmp r4, r3 // compare(qt * nv[array size - (n-1)], rt*divBase + nu[array size - 1 - (n-1+j)])
    bl pop_all
    bgt step3_aux // if qt * nv[array size - (n-1)] <= rt*divBase + nu[array size - 1 - (n-1+j)] --> step4s

    b step4

step3_aux:
    sub r4, r4, #1 // qt--

    ldr r11, =nv // ptr to nv
    sub r12, r10, r0
    ldr r11, [r11, r12] // f = nv[array size - n]
    add r3, r3, r11 // r = r+nv[n]

    cmp r3, r5 // compare(rt, divBase)
    bge step4 // if rt >= divBase -->step4
    b step3_loop


step4:
    bl push_all
    push {r10}
    ldr r11, =div_p
    push {r11}
    bl big_clear
    bl pop_all

    bl push_all
    ldr r11, =nv // ptr to nv
    push {r11}
    ldr r11, =temp_32
    push {r11}
    push {r10}
    bl big_rebase_32
    bl pop_all

    bl push_all
    sub r10, r10, #4
    lsr r10, r10, #1 
    ldr r11, =div_temp1
    str r4, [r11,r10] // str qt into temp vec
    bl pop_all

    bl push_all
    ldr r11, =temp_32 // ptr to nv
    push {r11} // pas nv
    ldr r11, =div_temp1
    push {r11}
    ldr r11, =div_p
    push {r11} // pas div_p
    sub r10, r10, #4
    lsr r10, r10, #1 
    push {r10} // pass array size
    bl big_mul
    bl pop_all

    bl push_all
    ldr r11, =div_p
    push {r11}
    ldr r11, =temp_32
    push {r11}
    push {r10}
    sub r10, r10, #4
    lsr r10, r10, #1
    push {r10}
    bl resize 
    bl pop_all

    bl push_all
    ldr r11, =temp_32
    push {r11}
    ldr r11, =div_p
    push {r11}
    sub r10, r10, #4
    lsr r10, r10, #1    
    push {r10}
    bl big_rebase_16
    bl pop_all

    mov r2, #0 // i = 0
step4_loop:
    bl push_all
    ldr r11, =div_p
    sub r0, r10 , r2 //size - i
    ldr r11, [r11, r0] //p[size-1 - i]

    add r0, r1, r2 // j+i
    sub r0, r10, r0 // size-1 - (j+i)
    vmov s2, r0 // store size-1 - (j+i)
    ldr r12, =nu
    ldr r12, [r12, r0] // nu[size-1 - (j+i)]

    cmp r11, r12 // compare (p[size-1 - i], nu[size-1 - (j+i)])
    vmov s0, r11 // store p[size-1 - i]
    vmov s1, r12 // store nu[size-1 - (j+i)]
    bl pop_all
    ble num_is_pos

    ldr r5, =divBase // divBase ptr
    ldr r5, [r5] // divBase value
    vmov r11, s1 // recover nu[size-1 - (j+i)]
    add r5, r5, r11 // divBase + nu[size-1 - (j+i)]
    vmov r11, s0 // recover p[size-1 - i]
    sub r5, r5, r11 // divBase + nu[size-1 - (j+i)] - p[size-1 - i]
    ldr r11, =nu // ptr to nu 
    vmov r12, s2 // recover size-1 - (j+i)
    str r5, [r11, r12] // nu[size-1 - (j+i)] = divBase + nu[size-1 - (j+i)] - p[size-1 - i]

    sub r12, r12, #4 // size-1 - (j+i+1)
    ldr r5, [r11, r12] // nu[size-1 - (j+i+1)]
    sub r5, r5, #1 // nu[size-1 - (j+i+1)] -1
    str r5, [r11, r12] // nu[size-1 - (j+i+1)] -= 1

    add r12, r0, #4 // n+1
    cmp r2, r12 // compare (i, n+1)
    bge step5 // i <= n+1 --> step4_loop
    add r2, r2, #4 // i ++
    b step4_loop

num_is_pos:
    ldr r11, =nu // ptr to nu
    vmov r12, s2 // recover size-1 - (j+i)  
    vmov r5, s0 // recover p[size-1 - i]
    ldr r6, [r11, r12] // nu[size-1 - (j+i)]
    sub r5, r6, r5 // nu[size-1 - (j+i)] - p[size-1 - i]
    str r5, [r11, r12] // nu[size-1 - (j+i)] = nu[size-1 - (j+i)] - p[size-1 - i]

    add r12, r0, #4 // n+1
    cmp r2, r12 // compare (i, n+1)
    bge step5 // i <= n+1 --> step4_loop
    add r2, r2, #4 // i ++
    b step4_loop
    
step5:
    sub r11, r10, r1 // array size - j
    str r4, [r8, r11] // q[array size - j] = qt

    sub r1, r1, #4 // j--
    cmp r1, #0 // j >= 0 ?
    bge step3 // if ( j >= 0) -> step3 again

    bl push_all
    ldr r11, =nu
    push {r11}
    ldr r11, =div_d
    ldr r11, [r11, r10]
    push {r11}
    push {r9}
    ldr r11, =div_p
    push {r11}
    push {r10}
    bl big_short_div
    bl pop_all

    //.ltorg  

    b end

big_short_div:
    pop {r10}   // pop divisor size (m)
    pop {r9}   // pop reminder ptr (r)
    pop {r8}   // pop quotient ptr (q)
    pop {r7}   // pop dividend v
    pop {r6}   // pop divisor ptr (u)

    push {lr}

    bl push_all
    push {r6} // pass u
    push {r10} // sizeof(u)
    bl big_length // l = big_length(u)
    vmov s0, r0 // preserve l
    bl pop_all
    vmov r0, s0 // recover l
    mov r1, #0 // rt = 0
big_short_div_loop:
    ldr r2, =divBase
    ldr r2, [r2] //r2 = divBase
    mul r2, r2, r1 // rt*divBase
    sub r3, r10, r0 // vec size - j
    ldr r3, [r6, r3] // u[vecsize-j]
    add r2, r2, r3 //e = rt*b+a_j
    // mov e and v to float and divide
    vmov s0, r2 // e
    vcvt.f32.u32 s0, s0

    vmov s1, r7 // v
    vcvt.f32.u32 s1, s1
    vdiv.f32 s0, s0, s1 // e/v
    // Move the result back to int registers
    vcvt.u32.f32 s0, s0
    vmov r1, s0 // e // v
    sub r3, r10, r0 // vec size - j
    str r1, [r8,r3] // q[vecsize-j] = e/v
    mul r1, r1, r7 // q[vecsize-j] * v
    sub r1, r2, r1 // rt = e%v

    cmp r0, #0 // l==0 ?
    streq r1, [r9] // r = rt
    beq end
    sub r0, r0, #4 // l--
    b big_short_div_loop
