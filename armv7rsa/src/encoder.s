//Computes the encryption key.
compute_e:
	ldr r4, =e
	ldr r5, =l
	ldr r6, =n
	ldr r7, =i

	push {lr}

	ldr r10, =size
	ldr r10, [r10]
	lsr r10, r10, #5
	sub r10, r10, #1
	lsl r10, r10, #2

compute_e_loop:
	bl push_all
	push {r7}
	push {r4}
	push {r7}
	push {r10}
	bl big_add
	bl pop_all

	bl push_all
	push {r7}
	push {r5}
	push {r10}
	bl big_cmp
	bl pop_all
	moveq r0, #1
	beq exit

	bl push_all
	push {r7}
	push {r5}
	push {r10}
	bl big_coprime
	bl pop_all

	bne compute_e_loop

	bl push_all
	push {r7}
	push {r6}
	push {r10}
	bl big_coprime
	bl pop_all
	bne compute_e_loop

	bl push_all
	push {r7}
	push {r4}
	push {r10}
	push {r10}
	bl resize
	bl pop_all

	b end

// Encodes msg
encode:
	push {lr}

	ldr r4, =msg
	ldr r5, =e
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
