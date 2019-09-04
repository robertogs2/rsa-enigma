compute_d:
	ldr r4, =d_temp
	ldr r5, =e
	ldr r6, =l

	push {lr}

	ldr r10, =size
	ldr r10, [r10]
	lsr r10, r10, #5
	sub r10, r10, #1
	lsl r10, r10, #2

	bl push_all
	push {r5}
	push {r6}
	push {r4}
	push {r10}
	bl big_modinv
	bl pop_all

	bl push_all
	add r4, r4, r10
	add r4, r4, #4
    push {r4}
    ldr r4, =d
    push {r4}
    push {r10}
    push {r10}
    bl resize 
    bl pop_all

	b end

// Decodes msg
decode:
	push {lr}

	ldr r4, =msg
	ldr r5, =d
	ldr r6, =n
	ldr r7, =num3

	mov r10, #12

	bl push_all
	push {r4}
	push {r5}
	push {r6}
	push {r7}
	push {r10}
	bl big_exp_mod
	bl pop_all


	b end
