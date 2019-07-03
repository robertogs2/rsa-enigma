
section .text

; Sets elements increasing, pointer to r12
set_incremented:

    ; Framing
    mov rbp, rsp

    ; Saves registers
    push    rbx
    push    r12

    mov     rbx, 0                       ; Starts counter
set_incremented_loop:
    ; Checks if its the end
    push    r12                          ; Saves register
    mov     r12, [array_size]            ; moves value of array_size to r12
    cmp     rbx, r12                     ; Check if value is the same
    pop     r12                          ; restores pointer of vector
    je      set_incremented_end          ; Go to end if its over

    mov     [r12+rbx*4], ebx             ; Stores the counter value in the index r12+rbx*4
    inc     rbx                          ; Increments index
    jmp     set_incremented_loop         ; Jumps to the loop again
set_incremented_end:

    ; Restores registers
    pop     r12
    pop     rbx

    ret

; Sets vector to 0, pointer to r12
reset_vector:

    ; Framing
    mov rbp, rsp

    push    rbx
    push    r12
    mov     rbx, 0                       ; Starts counter
reset_vector_loop:
    ; Checks if its the end
    push    r12;                         ; saves pointer of vector
    mov     r12, [array_size]            ; moves value of array_size to r12
    cmp     rbx, r12                     ; Check if value is the same
    pop     r12                          ; restores pointer of vector
    je      reset_vector_end          ; Go to end if its over

    mov     DWORD [r12+rbx*4], 0               ; Stores the 0 value in the index r12+rbx*4
    inc     rbx                          ; Increments index
    jmp     reset_vector_loop
reset_vector_end:
    pop     r12
    pop     rbx

    ret

; Sets vector to constant, pointer to r12, constant in rbx 
set_vector:

    ; Framing
    mov rbp, rsp

    ; Saves registers
    push    rbx
    push    r12

    call    reset_vector        ; First set all the vector to zero
    push    rbx                 ; Saves constant
    mov     rbx, [array_size]   ; Moves size of vector to rbx
    dec     rbx                 ; Removes one from size of rbx
    lea     r12, [r12 + 4*rbx]  ; Reads address to place constant
    pop     rbx                 ; Gets constant again
    mov     [r12], rbx          ; Stores rbx constant in memory position of first element

    ; Restores registers
    pop     r12
    pop     rbx

    ret

; Length of a vector, pointer in r12
big_length:

    ; Framing
    mov rbp, rsp

    ; 
    push r12
    push rbx
    push rax
    push rcx
    push rdx

    mov DWORD [lengthL], 0          ; First length will be zero
    mov rbx, 0
big_length_loop:
    cmp rbx, [array_size]
    je big_length_end
    cmp DWORD [r12+4*rbx], 0
    jne big_length_end
    inc rbx
    jmp big_length_loop
big_length_end:
    neg rbx                 ; -i
    add rbx, [array_size]   ; -i+array_size
    mov DWORD [lengthL], ebx ; lengthL has array_size-i

    pop rdx
    pop rcx
    pop rax
    pop rbx
    pop r12

    ret

; Compares to big number
; comA and comB have pointers
; comRes has result
; 0 equal, 1 a > b, 2 a < b

big_compare:

    ; Framing
    mov rbp, rsp

    ; Saves registers
    push r12
    push rbx
    push rax
    push rcx
    push rdx

    xor r12, r12                ; Zero to r12
    mov rbx, 0                  ; Starts counter
    mov DWORD [comRes], 0       ; Result is set to zero at the start
big_compare_loop:
    cmp rbx, [array_size]       ; Compares the counter with the size of the array
    je big_compare_end          ; If its end, jump to the end
    mov r12d, DWORD [comA]      ; Pointer of vector a
    mov r12d, DWORD [r12+4*rbx] ; a[i]
    push r12                    ; Saves the r12 register
    mov r12d, DWORD [comB]      ; Pointer of vector b
    mov r12d, DWORD [r12+4*rbx] ; b[i]
    mov rax, r12                ; rax has b[i]
    pop r12                     ; r12 has a[i]

    inc rbx                     ; Increments counter
    cmp r12, rax                ; r12 # rax
    je big_compare_loop         ; Same, keep looking

    jl big_compare_case_less    ; Case if a < b, jump to that case

    mov DWORD [comRes], 1       ; Moves one for the case a>b
    jmp big_compare_end         ; Jump to the end
big_compare_case_less:
    mov DWORD [comRes], 2       ; Moves 2 for the case a<b
big_compare_end:
    
    ; Restores registers
    pop rdx
    pop rcx
    pop rax
    pop rbx
    pop r12

    ret

; Copies one vector into another
big_copy:

    ; Framing
    mov rbp, rsp

    push r12
    push rbx
    push rax
    push rcx
    push rdx

    mov rbx, 0
big_copy_loop:
    cmp rbx, [array_size]
    je big_copy_end
    mov r12d, DWORD [copA]
    mov r12d, DWORD [r12 +4*rbx] ; r12 has a[i]

    push r12                    ; saves value of a[i]
    ;loads address for copy vector
    mov r12d, DWORD [copB]
    lea r12, [r12+4*rbx]
    ;Saves value in that address
    pop rax
    mov DWORD [r12], eax ;rax has a[i], r12 has the b[i] address

    inc rbx
    jmp big_copy_loop
big_copy_end:
    
    pop rdx
    pop rcx
    pop rax
    pop rbx
    pop r12

    ret

; Adds 2 vectors
big_add:  

    ; Framing
    mov rbp, rsp

    push    rbx
    push    r12
    push    rcx
    push    rax
    push    rdx

    mov     DWORD [carry], 0                  ; Sets carry to 0
    mov     DWORD [old_carry], 0              ; Sets old carry to 0
    mov     rbx, [array_size]           ; Counter for the elements
big_add_loop:
    ; Check if it's the end
    
    cmp     rbx, 0                      ; Compare size to counter
    je      big_add_end                 ; Jump if finish
    dec     rbx                         ; Decrements the index at the start

    mov     ecx, DWORD [sumB]                ; Takes pointer to start of second vector 
    mov     r12d, DWORD [sumA]                  ; Takes pointer to start of first vector

    mov     ecx, [rcx+rbx*4]      ; Takes value for the i element of second vector
    mov     r12d, [r12+rbx*4]      ; Takes value for the i element of first vector

    ; Old carry now has the previous carry
    push    r12
    mov     r12d, DWORD [carry]
    mov     DWORD [old_carry], r12d 
    mov     DWORD [carry], 0            ; Resets the carry
    pop     r12
    
    add     ecx, r12d                    ; Sums the value ecx=ecx+r12d
    adc     DWORD [carry], 0            ; Adds carry to carry
    mov     r12d, DWORD [old_carry]      ; Sets the previous carry to 
    add     ecx, r12d                    ; Sum the previous carry
    adc     DWORD [carry], 0            ; Adds carry to carry
    
    mov     r12d, [sumC]              ; Takes the pointer to vector of vectors
    mov     DWORD [r12+rbx*4], ecx      ; Saves the result from the previous sum to i element of third vector

    jmp     big_add_loop
big_add_end:
    
    pop     rdx
    pop     rax
    pop     rcx
    pop     r12
    pop     rbx

    ret

; Subs 2 vectors
; Uses pivot1
big_sub:  

    ; Framing
    mov rbp, rsp

    push    rbx
    push    r12
    push    rcx

    mov     DWORD [carry], 0                  ; Sets carry to 0
    mov     DWORD [old_carry], 0              ; Sets old carry to 0
    mov     rbx, [array_size]           ; Counter for the elements
big_sub_loop:
    ; Check if it's the end
    
    cmp     rbx, 0                      ; Compare size to counter
    je      big_sub_end                 ; Jump if finish
    dec     rbx                         ; Decrements the index at the start

    mov     ecx, DWORD [subB]                ; Takes pointer to start of second vector 
    mov     r12d, DWORD [subA]                  ; Takes pointer to start of first vector

    mov     ecx, [rcx+rbx*4]      ; Takes value for the i element of second vector
    mov     r12d, [r12+rbx*4]      ; Takes value for the i element of first vector

    ; Old carry now has the previous carry
    push    r12
    mov     r12d, DWORD [carry]
    mov     DWORD [old_carry], r12d 
    mov     DWORD [carry], 0            ; Resets the carry
    pop     r12
    
    not     ecx                         ; Negates ecx or b element
    add     ecx, r12d                    ; Sums the value ecx=ecx+r12d
    adc     DWORD [carry], 0            ; Adds carry to carry
    mov     r12d, DWORD [old_carry]      ; Sets the previous carry to 
    add     ecx, r12d                    ; Sum the previous carry
    adc     DWORD [carry], 0            ; Adds carry to carry
    
    mov     r12d, [subC]              ; Takes the pointer to vector of vectors
    mov     DWORD [r12+rbx*4], ecx      ; Saves the result from the previous sum to i element of third vector

    jmp     big_sub_loop
big_sub_end:

    mov     r12, pivot1
    mov     rbx, 1
    call    set_vector ; sets pivot 1 first element to 1

    ;following code sums one
    mov     r12, [subC] 
    mov     [sumA], r12
    mov     DWORD [sumB], pivot1
    mov     [sumC], r12
    call    big_add
    
    pop     rcx
    pop     r12
    pop     rbx

    ret

; multiplication of big numbers
; mul_index are the indexi and indexj
; mul_x is each counter
; Uses pivot1
big_mul:

    ; Framing
    mov rbp, rsp

    push r12;
    push rbx
    push rax
    push rdx
    push rcx

    mov  r12, [mulC]
    call reset_vector
    mov DWORD [low], 0
    mov DWORD [high], 0
    mov DWORD [mul_indexi], 0
    mov DWORD [mul_indexj], 0
    mov DWORD [mul_i], 0
    mov DWORD [mul_j], 0

    mov r12, pivot1
    call reset_vector
    mov rbx, 0
big_mul_loop_i:
    push rbx
    mov ebx, DWORD [mul_i]
    cmp ebx, DWORD [array_size]
    pop rbx
    je big_mul_end

    ;calc indexi = array_size-i-1
    push rbx
    mov rbx, [array_size];
    sub rbx, [mul_i]
    dec rbx                     ; rbx = array_size-i-1
    mov [mul_indexi], rbx
    pop rbx

    mov DWORD [low], 0 ; resets low
    mov DWORD [high], 0 ; resets high
    mov DWORD [mul_j], 0
big_mul_loop_j:
    
    push rbx
    mov  ebx, DWORD [mul_j]
    cmp  ebx, DWORD [array_size]
    pop  rbx
    je   big_mul_loop_j_end

    ; calc indexj = array_size-j-1
    push rbx
    mov ebx, DWORD [array_size];
    sub ebx, DWORD [mul_j]
    dec ebx                     ; rbx = array_size-j-1
    mov DWORD [mul_indexj], ebx
    pop rbx

    ; calc i+j and Compare with array_size
    push rbx
    mov ebx, DWORD [mul_i]
    add ebx, DWORD [mul_j]
    cmp ebx, DWORD [array_size]
    inc DWORD [mul_j]
    pop rbx
    jae big_mul_loop_j ;jumps to j for if not meet

    ; Actual multiplication, check for dwords...
    push rbx
    push r12
    ;b load
    mov ebx, DWORD [mul_indexi]
    mov r12d, DWORD [mulB]
    mov r12d, DWORD [r12+4*rbx]
    mov rax, 0              ; resets rax
    mov rax, r12            ; rax has b[indexi]
    ;a load
    mov ebx, DWORD [mul_indexj]
    mov r12d, DWORD [mulA]
    mov r12d, DWORD [r12+4*rbx]    ; r12 has a[indexj]
    ;multiplication
    mul r12                 ; rax = rax * r12 
    ; low = mul
    mov DWORD [low], eax    ;lower of multiplication
    pop r12
    pop rbx
    ; Resets d
    mov r12, pivot1
    call reset_vector
    ; Sets mul or low for d
    mov ebx, DWORD [mul_indexj]
    sub ebx, DWORD [mul_i]
    lea r12, [r12+4*rbx]
    mov ebx, DWORD [low]
    mov DWORD [r12], ebx
    ; Adds to current value
    mov rbx, [mulC]
    mov [sumA], rbx
    mov DWORD [sumB], pivot1
    mov [sumC], rbx
    call big_add
    ; Resetss d again
    mov r12, pivot1
    call reset_vector
    ;Sets high for d
    mov ebx,DWORD  [mul_indexj]
    sub ebx, DWORD [mul_i]
    lea r12, [r12+4*rbx]
    mov ebx, DWORD [high]
    mov [r12], rbx
    ; Adds to current value
    mov rbx, [mulC]
    mov [sumA], rbx
    mov DWORD [sumB], pivot1
    mov [sumC], rbx
    call big_add
    ; Sets for the new high
    shr rax, 32; shift right logical
    mov [high], rax
    jmp big_mul_loop_j
big_mul_loop_j_end:
    inc DWORD [mul_i]
    jmp big_mul_loop_i
big_mul_end:

    pop rcx
    pop rdx
    pop rax
    pop rbx
    pop r12

    ret

; short division
big_short_div:

    ; Framing
    mov rbp, rsp

    push rbx
    push r12
    push rax
    push rdx
    push rcx
    xor r12, r12
    mov r12d, DWORD [sDivA] ; pointer to a vector
    call big_length
    dec DWORD [lengthL] ; use it as j
    mov DWORD [sDivR], 0 ; use it as rt and r
big_short_div_loop:
    cmp DWORD [lengthL], 0
    jl big_short_div_end
    
    xor rax, rax
    mov eax, DWORD [sDivR]
    mul QWORD [base]               ; rax = rt*base
    
    xor rbx, rbx
    mov ebx, DWORD [lengthL]        ; rbx has j
    inc ebx                         ; rbx has j+1
    neg ebx                         ; rbx has -j-1
    add ebx, DWORD [array_size]     ; rbx has array_size-1-j
    push rbx

    xor r12, r12
    mov r12d, DWORD [sDivA]          ; pointer to A
    mov ebx, DWORD [r12 + 4*rbx]    ; a_j
    add rax, rbx                    ; rax = rt*base+a_j = e

    xor rdx, rdx
    xor rbx, rbx
    mov ebx, DWORD [sDivB] 
    div rbx                         ; e/v = e/b = rax/b now rax has the division and rdx has modulus
    
    mov DWORD [sDivR], edx          ; rt =e%v
    xor rdx, rdx
    pop rbx                         ; rbx = array_size-1-j
    xor r12, r12
    mov r12d, DWORD [sDivQ]          ; pointer to q
    mov DWORD [r12+4*rbx], eax      ; q[array_size-1-j] = e/v

    dec DWORD [lengthL]
    jmp big_short_div_loop
big_short_div_end:
    pop rcx
    pop rdx
    pop rax
    pop r12
    pop rbx

    ret

; Long division, if Q and R are same pointer, R is supposed to be set
; Uses pivot2 and pivot3
big_long_div:

    ; Framing
    mov rbp, rsp

    push r12
    push rbx
    push rax
    push rcx
    push rdx

    mov r12d, DWORD [lDivQ]
    call reset_vector
    mov r12d, DWORD [lDivR]
    call reset_vector

    mov r12, pivot2 
    call reset_vector             ; resets pivot vector 2

    ; Length for A
    mov r12d, DWORD [lDivA]        
    call big_length
    mov r12d, DWORD [lengthL]        ; Length of A
    mov DWORD [div_l], r12d          ; Length of A to l

    ; Length for B
    mov r12d, DWORD [lDivB]        
    call big_length
    mov r12d, DWORD [lengthL]        ; Length of B
    mov DWORD [div_n], r12d          ; Length of B to n

    ; Moves both vector pointers 
    mov r12d, DWORD [lDivA]
    mov DWORD [comA], r12d
    mov r12d, DWORD [lDivB]
    mov DWORD [comB], r12d

    ; Compare both vectors
    call big_compare
    mov r12d, DWORD [comRes]        ; r12 has the comparision

    ; If a is less than b, just copy
    cmp r12d, 2
    je big_long_div_case1

    ; If the length of B is one, use short division
    mov r12d, DWORD [div_n]
    cmp r12d, 1
    je big_long_div_case2

    ; Else perform the long division
    jmp big_long_div_case3
big_long_div_case1:
    ; Reset of quotient and copy of a
    ; Reset of quotient
    mov r12d, DWORD [lDivQ]
    call reset_vector
    ; Copy a to the remainder
    mov r12d, DWORD [lDivA]
    mov DWORD [copA], r12d
    mov r12d, DWORD [lDivR]
    mov DWORD [copB], r12d
    call big_copy

    jmp big_long_div_end
big_long_div_case2:
    ; Call to short division

    ; Mov A pointer
    mov r12d, DWORD [lDivA]
    mov DWORD [sDivA], r12d

    ; Mov B value
    mov r12d, DWORD [lDivB]
    mov ebx, DWORD [array_size]
    dec ebx
    mov r12d, DWORD [r12+4*rbx] ;Last element of B
    mov DWORD [sDivB], r12d

    ; Mov Q pointer
    mov r12d, DWORD [lDivQ]
    mov DWORD [sDivQ], r12d

    ; With A, B and Q, call short division
    call big_short_div
    mov r12d, DWORD [lDivR]
    mov ebx, DWORD [sDivR]
    call set_vector

    jmp big_long_div_end
big_long_div_case3:
    ; Sorry, long division algorithm in here
    xor r12, r12
    ; j=m=l-n
    mov r12d, DWORD [div_l]
    sub r12d, DWORD [div_n]
    mov DWORD [div_j], r12d

    ; Reset v and u
    mov r12, div_u
    call reset_vector
    mov r12, div_v
    call reset_vector

    ; Calculation of d

    mov rbx, [array_size]
    sub ebx, DWORD [div_n]
    xor r12, r12
    mov r12d, DWORD [lDivB]
    mov ebx, DWORD [r12 + 4*rbx] ;ebx = b[array_size-1-(n-1)]  

    inc rbx
    xor rdx, rdx                ; Added to fix
    mov rax, QWORD [base]
    div rbx                     ; base / ebx
    mov DWORD [div_d], eax

    ; Step 1
    ; Set d to vector pivto2
    mov r12, pivot2
    mov ebx, DWORD [div_d]
    call set_vector

    ; u = a*d
    mov DWORD [mulC], div_u
    mov r12d, DWORD [lDivA]
    mov DWORD [mulA], r12d
    mov DWORD [mulB], pivot2
    call big_mul
   
    
    ; v = b*d
    mov DWORD [mulC], div_v
    mov r12d, DWORD [lDivB]
    mov DWORD [mulA], r12d
    call big_mul

    ; Step 2
    mov DWORD [div_e], 0
    mov DWORD [div_f], 0
    mov DWORD [div_qt], 0
    mov DWORD [div_rt], 0
big_long_div_case3_loop_j:

    cmp DWORD [div_j], 0
    jl big_long_div_case3_loop_j_end

    ; Step 3
    ; e calculation
    xor rbx, rbx
    xor r12, r12
    mov rbx, [array_size]
    dec rbx
    sub ebx, DWORD [div_n]
    sub ebx, DWORD [div_j]          ; array_size-1-n-j
    mov r12, div_u  

    xor rax, rax                
    mov eax, DWORD [r12 + 4*rbx] 
    mul QWORD [base]                ; rax*base

    inc rbx                         ; array_size-1-n-j+1
    mov r12d, DWORD [r12+4*rbx]
    add rax, r12
    mov QWORD [div_e], rax

    ; f calculation
    add ebx, DWORD [div_j]          ; array_size-1-n+1
    mov r12, div_v
    mov r12d, DWORD [r12+4*rbx]
    mov QWORD [div_f], r12

    ; qt and rt
    xor rdx, rdx
    mov r12, QWORD [div_f]
    mov rax, QWORD [div_e]
    div r12                         ; e/f

    mov QWORD [div_qt], rax
    mov QWORD [div_rt], rdx

    inc rbx                         ; array_size-1-n+2
big_long_div_case3_while:

    mov r12, QWORD [div_qt]
    cmp r12, QWORD [base]
    jae big_long_div_case3_while_cond1

    mov r12, div_v
    xor rax, rax
    mov eax, DWORD [r12+4*rbx]      ; v[array_size-1-(n-2)]
    
    xor r12, r12
    mov r12, QWORD [div_qt]
    mul r12              ; rax has first multiplication

    push rax
    xor rax, rax
    mov rax, QWORD [div_rt]
    mul QWORD [base]                ; base*rt
    mov r12, div_u
    sub ebx, DWORD [div_j]          ; array_size-1-n-j+2
    
    xor rcx, rcx
    mov ecx, DWORD [r12+4*rbx]
    add rax, rcx      ; +u[array_size-1-(n+j-2)]

    add ebx, DWORD [div_j]          ; array_size-1-n+2
    pop r12                         ; first multiplication in r12
    cmp r12, rax
    ja big_long_div_case3_while_cond1

    jmp big_long_div_case3_while_end ;No condition met
big_long_div_case3_while_cond1:
    
    dec QWORD [div_qt]              ; qt--
    mov rax, QWORD [div_f]          
    add QWORD [div_rt], rax         ; rt += f

    mov rax, QWORD [div_rt]
    cmp rax, QWORD [base]
    jae big_long_div_case3_while_end    ; rt >= base
    jmp big_long_div_case3_while        ; while again
big_long_div_case3_while_end:

    ;step 4
    ; pivot2 has only qt
    mov r12, pivot2
    call reset_vector
    mov rbx, QWORD [div_qt]
    call set_vector
    ; scaling v by qt
    mov DWORD [mulB], r12d           ;pivot2 to B mul
    mov DWORD [mulA], div_v         ;div_v to A mul
    mov DWORD [mulC], pivot3        ;pivot3 with result
    call big_mul

    ; saving qt to q
    xor rbx, rbx
    xor r12, r12
    mov rbx, [array_size]
    dec rbx
    sub ebx, DWORD [div_j]          ; rbx = array_size-1-j 
    mov r12d, DWORD [lDivQ]       
    mov rax, QWORD [div_qt]   
    mov DWORD [r12+4*rbx], eax      ; step 5

    ; loop for p and u
    xor rbx, rbx                    ; rbx has i
big_long_div_case3_loop_i:
    
    xor r12, r12
    mov r12, [array_size]           
    dec r12
    sub r12, rbx                    ; r12 has array_size-1-i

    ; takes required elements
    xor rax, rax
    xor rdx, rdx
    mov eax, DWORD [pivot3+4*r12]   ; eax has p element
    sub r12d, DWORD [div_j]          ; r12 has array_size-1-i-j
    mov edx, DWORD [div_u+4*r12]    ; edx has u element

    ; compares if p element is bigger than the one from u
    cmp eax, edx
    ja big_long_div_case3_loop_i_if ; Case its gonna be negative
    
    ; this is the else
    sub edx, eax                    ; u-p
    mov DWORD [div_u+4*r12], edx    ; u = u-p

    ; check if we need to loop again
    inc rbx
    cmp ebx, DWORD [div_n]
    
    ;Still havent reach n+1
    jle big_long_div_case3_loop_i
    
    ; Reached n+1, we end
    jmp big_long_div_case3_loop_i_end
big_long_div_case3_loop_i_if:
    mov rcx, QWORD [base]
    add rcx, rdx
    sub rcx, rax
    mov DWORD [div_u+4*r12], ecx

    dec r12
    dec DWORD [div_u+4*r12]

    ; replicated
    inc rbx
    cmp ebx, DWORD [div_n]
    jle big_long_div_case3_loop_i
big_long_div_case3_loop_i_end:
    ; final block for j loop, go back up
    dec DWORD [div_j]
    jmp big_long_div_case3_loop_j
big_long_div_case3_loop_j_end:
    ; Call to the short division for remainder
    mov r12d, DWORD [lDivR]
    mov DWORD [sDivQ], r12d
    mov r12d, DWORD [div_d]
    mov DWORD [sDivB], r12d
    mov DWORD [sDivA], div_u
    call big_short_div
    
    jmp big_long_div_end
big_long_div_end:

    pop rdx
    pop rcx
    pop rax
    pop rbx
    pop r12

    ret

; Increment by one, pointer in r12
big_increment:

    ; Framing
    mov rbp, rsp

    push r12
    push rbx
    push rax

    mov rax, r12
    mov r12, pivot1
    mov rbx, 1
    call set_vector

    mov DWORD [sumA], r12d
    mov DWORD [sumB], eax
    mov DWORD [sumC], eax
    call big_add

    pop rax
    pop rbx
    pop r12

    ret

; Decrements by one, pointer in r12
big_decrement:

    ; Framing
    mov rbp, rsp

    push r12
    push rbx
    push rax

    mov rax, r12
    mov r12, pivot1
    mov rbx, 1
    call set_vector

    ; eax has now pointer to our vector
    mov DWORD [subB], r12d
    mov DWORD [subA], eax
    mov DWORD [subC], eax
    call big_sub

    pop rax
    pop rbx
    pop r12

    ret

; Checks if a number is divisible by 2, pointer in r12
; r12 has modulus
big_modulus2:

    ; Framing
    mov rbp, rsp

    push r12
    push rbx

    mov rbx, [array_size]
    dec rbx
    mov r12d, DWORD [r12+4*rbx]    ; Last element of vector
    and r12, 1

    pop rbx
    pop r12

    ret

; Modular Exponentiation algorithm
; Variables located in memory
; Uses pivot4, and 2
big_modular_exponentiation:

    ; Framing
    mov rbp, rsp
    
    push rcx
    push rdx
    push rax
    push r12
    push rbx

    ; Setting r in r12 to 1
    xor r12, r12
    mov r12d, DWORD [exp_modR]
    mov rbx, 1
    call set_vector

    ; We need to iterate over all bits, so over all dwords first

    ; For all the dwords
    mov r13, 0
big_modular_exponentiation_words:
    
    ; Compares for the end of all dwords
    cmp r13, [array_size]
    je big_modular_exponentiation_end

    ; Gets the corresponding dword, or e
    xor r14, r14
    mov r14d, DWORD [exp_modE] 
    mov r14d, DWORD [r14 + 4*r13]

    inc r13 ; Increments current dword for next iteration

    ; Call to observe current dword iteration
    call print_char

    xor rbx, rbx
    mov rbx, [dword_bits] ; moves 32
    dec rbx ; Sets rbx as 31
big_modular_exponentiation_words_bits:

    ; Check if current iteration of bits is over
    cmp rbx, 0
    jl big_modular_exponentiation_words

    ; r*r in pivot2
    mov r12d, DWORD [exp_modR]
    mov DWORD [mulA], r12d
    mov DWORD [mulB], r12d
    mov DWORD [mulC], pivot2
    call big_mul

    ; copies pivot2 to r, r=r*r
    mov r12d, DWORD [exp_modR]
    mov DWORD [copA], pivot2
    mov DWORD [copB], r12d
    call big_copy

    ; moves pointer for division, pivot4 will have r*r%m
    mov r12d, DWORD [exp_modR]
    mov DWORD [lDivQ], pivot5
    mov DWORD [lDivR], pivot4
    mov eax, DWORD [exp_modM] 
    mov DWORD [lDivB], eax ; m pointer
    mov DWORD [lDivA], r12d
    call big_long_div

    ; copies pivot4 in r, r=r*r%m
    mov r12d, DWORD [exp_modR]
    mov DWORD [copA], pivot4
    mov DWORD [copB], r12d
    call big_copy

    ; e last bit and comparation
    push r14
    mov rcx, rbx
    shr r14d, cl    ; Shift according to the amount of current bits, lower of rbx
    and r14d, 1     ; Gets only last bit

    ; Compares if that bit is zero, avoid the operation
    cmp r14d, 0
    pop r14
    je big_modular_exponentiation_words_bits_zero

    ; Resets pivot2
    push r12
    mov r12, pivot2
    call reset_vector
    pop r12

    ; r*b in pivot2
    mov r12d, DWORD [exp_modR]
    mov DWORD [mulA], r12d
    mov r12d, DWORD [exp_modB]
    mov DWORD [mulB], r12d
    mov DWORD [mulC], pivot2
    call big_mul

    ; copies pivot2 to r, r=r*b
    mov r12d, DWORD [exp_modR]
    mov DWORD [copA], pivot2
    mov DWORD [copB], r12d
    call big_copy

    ; moves pointer for division, pivot4 will have r*b%m
    mov DWORD [lDivQ], pivot5
    mov DWORD [lDivR], pivot4
    mov r12d, DWORD [exp_modM]
    mov DWORD [lDivB], r12d ; m pointer
    mov r12d, DWORD [exp_modR]
    mov DWORD [lDivA], r12d
    call big_long_div

    ; copies pivot4 in r, r=r*b%m
    mov r12d, DWORD [exp_modR]
    mov DWORD [copA], pivot4
    mov DWORD [copB], r12d
    call big_copy
big_modular_exponentiation_words_bits_zero:

    ; Decrements the bits
    dec rbx
    jmp big_modular_exponentiation_words_bits
big_modular_exponentiation_end:
    
    pop rbx
    pop r12
    pop rax
    pop rdx
    pop rcx

    ret

; Greatest common divisor
; Pointers in memory
; Uses pivot4 and 5 and 6
big_gcd:
    push rcx
    push rdx
    push rax
    push r12
    push rbx

    ; Resets pivots
    mov r12, pivot4
    call reset_vector
    mov r12, pivot5
    call reset_vector
    mov r12, pivot6
    call reset_vector

    ; Resets out vector
    mov r12d, DWORD [gcdR]
    call reset_vector
    
    ; Copies A into result, this will be the algorithm a variable
    mov r12d, DWORD [gcdA]
    mov DWORD [copA], r12d
    mov r12d, DWORD [gcdR]
    mov DWORD [copB], r12d
    call big_copy
    
    ; Copies B into pivot4
    mov r12d, DWORD [gcdB]
    mov DWORD [copA], r12d
    mov r12d, pivot4
    mov DWORD [copB], r12d
    call big_copy
    
    ; Now result has a, pivot 4 is b, and pivot 5 is t
    ; Pivot 6 is used for modulus
big_gcd_loop:
    
    ; Checks if b is zero
    mov DWORD [conA], pivot4
    mov DWORD [conC], 0
    call big_cons
    
    ; Actual b zero flag, if its zero, jump
    cmp DWORD [conR], 1
    je big_gcd_end
    
    ; Copies b to t, ie pivot4 to pivot5
    mov DWORD [copA], pivot4
    mov DWORD [copB], pivot5
    call big_copy

    ; Calculates a%b, ie result modulus pivot4, this goes to pivot6
    mov r12d, DWORD [gcdR]
    mov DWORD [lDivA], r12d
    mov DWORD [lDivB], pivot4
    mov DWORD [lDivQ], pivot6
    mov DWORD [lDivR], pivot6
    call big_long_div

    ; Moves a%b to b, ie pivot6 to pivot4
    mov DWORD [copA], pivot6
    mov DWORD [copB], pivot4
    call big_copy

    ; Copies t in into a, ie pivot5 into result
    mov DWORD [copA], pivot5
    mov r12d, DWORD [gcdR]
    mov DWORD [copB], r12d
    call big_copy

    jmp big_gcd_loop
big_gcd_end:

    pop rbx
    pop r12
    pop rax
    pop rdx
    pop rcx

    ret


; Inverse to solve (de)%l=1, use pivot4
big_inverse:
    
    push rcx
    push rdx
    push rax
    push r12
    push rbx
    
    ; Starts all Variables
    mov r12, invInv
    call reset_vector
    mov r12, invU1 
    call reset_vector
    mov r12, invU3 
    call reset_vector
    mov r12, invV1 
    call reset_vector
    mov r12, invV3 
    call reset_vector
    mov r12, invT1 
    call reset_vector
    mov r12, invT3 
    call reset_vector
    mov r12, invQ  
    call reset_vector
    mov DWORD [invIter], 1

    ; Sets u1 to 1
    mov r12, invU1
    mov rbx, 1
    call set_vector
    
    ; Sets u3 to e
    mov eax, DWORD [invE]
    mov DWORD [copA], eax
    mov DWORD [copB], invU3
    call big_copy

    ; Sets v3 to l
    mov eax, DWORD [invL]
    mov DWORD [copA], eax
    mov DWORD [copB], invV3
    call big_copy
big_inverse_loop:

    
    ; Compare v3 with 0

    mov DWORD [conA], invV3
    mov DWORD [conC], 0
    call big_cons

    ;mov r12, invV3
    call print_char 
    cmp DWORD [conR], 1
    je big_inverse_loop_end ; If its zero, end

    ; First division
    mov DWORD [lDivA], invU3
    mov DWORD [lDivB], invV3
    mov DWORD [lDivQ], invQ
    mov DWORD [lDivR], invT3
    call big_long_div

    ; t1 = u1 + q*v1
    mov DWORD [mulC], pivot4
    mov DWORD [mulA], invQ
    mov DWORD [mulB], invV1 
    call big_mul
    mov DWORD [sumA], pivot4
    mov DWORD [sumB], invU1
    mov DWORD [sumC], invT1
    call big_add

    ; Other copies

    mov DWORD [copA], invV1
    mov DWORD [copB], invU1
    call big_copy
    mov DWORD [copA], invT1
    mov DWORD [copB], invV1
    call big_copy
    mov DWORD [copA], invV3
    mov DWORD [copB], invU3
    call big_copy
    mov DWORD [copA], invT3
    mov DWORD [copB], invV3
    call big_copy

    ; iter = !iter
    xor DWORD [invIter], 1

    call print_char

    jmp big_inverse_loop
big_inverse_loop_end:

    ; Compares u3 with 1
    mov DWORD [conA], invU3
    mov DWORD [conC], 1
    call big_cons

    cmp DWORD [conR], 1 ; U3 is 1
    je big_inverse_end1 ; If u3 == 1, jump

    ; didnt, jump U3 != 1
    mov r12, invInv
    call reset_vector
    jmp big_inverse_end
big_inverse_end1:
    
    ; if iter is 0
    cmp DWORD[invIter], 0
    jne big_inverse_end2 ; if its 1 jump
    
    ; inv is l - u1
    mov eax, DWORD [invL]
    mov DWORD [subA], eax
    mov DWORD [subB], invU1
    mov DWORD [subC], invInv

    call print_char

    call big_sub

    jmp big_inverse_end
big_inverse_end2:
    
    ; Copies u1 into inv
    mov DWORD [copA], invU1
    mov DWORD [copB], invInv
    call big_copy
big_inverse_end:
    
    ; Copies Inv to output
    mov DWORD [copA], invInv
    mov eax, DWORD [invR]
    mov DWORD [copB], eax
    call big_copy

    pop rbx
    pop r12
    pop rax
    pop rdx
    pop rcx

    ret

; Checks if a number is a constant
; Result in flag of function, 1 if yes, 0 if not
big_cons:
    
    push rbx
    push rax
    push rcx
    push rdx
    push r12
    
    ; Sets a pivot vector
    xor rbx, rbx
    mov r12, pivot1
    mov ebx, DWORD [conC]
    call set_vector
    
    ; Compares pivot with original vector
    mov DWORD [comA], pivot1
    mov eax, DWORD [conA]
    mov DWORD [comB], eax
    call big_compare


    mov DWORD [conR], 0
    cmp DWORD [comRes], 0 ; Meaning they are the same
    jne big_cons_end    ; if not the same jump

    mov DWORD [conR], 1 ; They are the same
big_cons_end:

    pop r12
    pop rdx
    pop rcx
    pop rax
    pop rbx
    ret

; Calculates coprime or gcd(e,L)=1
; Uses pivot2 and pivot3, for gcd uses vector of inverse invT1
big_coprime:
    push rcx
    push rdx
    push rax
    push r12
    push rbx

    mov r12d, DWORD [coprE]
    call reset_vector

    ; random dword calculation, ie length of l minus 1
    ; double size of primes by 2 in dowrds minus 1
    ; Or maximun dword operation minus 1, divided by 2, minus 1
    xor rax, rax
    mov rax, [array_size]
    dec rax
    shr rax, 1
    dec rax
    dec rax

    mov r12d, DWORD [coprE]
    mov DWORD [randA], r12d
    mov DWORD [randS], eax
    call big_random
big_coprime_loop:

    ; Calculates gcd for e,l
    mov eax, DWORD [coprE]
    mov DWORD [gcdA], eax
    mov eax, DWORD [coprL]
    mov DWORD [gcdB], eax
    mov DWORD [gcdR], invT1
    call big_gcd

    ; Checks if result is 1

    mov DWORD [conC], 1
    mov DWORD [conA], invT1
    call big_cons
    cmp DWORD [conR], 1
    je big_coprime_end ;Jump if gcd is 1

    ; Increments E by one 
    mov r12d, DWORD [coprE]
    call big_increment

    jmp big_coprime_loop    
big_coprime_end:
    pop rbx
    pop r12
    pop rax
    pop rdx
    pop rcx

    ret

; Generates a random number

big_random:
    push rcx
    push rdx
    push rax
    push r12
    push rbx

    ; Double counter...
    mov rbx, [array_size]
    dec rbx
    mov rax, 0
big_random_loop:
    cmp DWORD [randS], eax
    je big_random_end

    
    xor rcx, rcx
    mov ecx, DWORD [randA] ; pointer to vector
    rdseed r12d ; random 32 bit number
    mov DWORD [rcx+4*rbx], r12d ; moves random number to memory position

    inc rax
    dec rbx
    jmp big_random_loop
big_random_end:
    pop rbx
    pop r12
    pop rax
    pop rdx
    pop rcx

    ret
