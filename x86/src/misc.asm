section .text

; Flips bytes for each dwrod
; r12 has pointer
flip_array:

    ; Framing
    mov rbp, rsp

    push r12
    push rbx
    push rax
    xor rbx, rbx
flip_array_loop:
    cmp rbx, [array_size]
    je flip_end
    
    mov eax, DWORD [r12+4*rbx]        ; Gets rbx counter word
    bswap eax
    mov DWORD [r12+4*rbx], eax
    inc rbx
    jmp flip_array_loop
flip_end:
    pop rax
    pop rbx
    pop r12

    ret

print_char:
    push rdi
    push rsi
    push rdx
    push rax
    push rbp
    push rsp
    ; Print that read value
    mov rdi, 1  ; write in stdout
    mov rsi, testing
    mov rdx, 1
    mov rax, 1
    syscall
    pop rsp
    pop rbp
    pop rax
    pop rdx
    pop rsi
    pop rdi
    ret

print_newline:
    push rdi
    push rsi
    push rdx
    push rax
    push rbp
    push rsp
    ; Print that read value
    mov rdi, 1  ; write in stdout
    mov rsi, format_new_line
    mov rdx, 1
    mov rax, 1
    syscall
    pop rsp
    pop rbp
    pop rax
    pop rdx
    pop rsi
    pop rdi
    ret

; Loads the required prime numbers from the specified files, 
; generate the keys and save them
prime_load:
    
    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Opens file 1
    mov rdi, prime1file
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; saves file descriptor
    
    ; Opens file 2
    mov rdi, prime2file
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd2], rax
    
    ; Calculation for prime loading offset
    xor rax, rax
    xor rbx, rbx
    mov rbx, [prime_bits] ;Gets amount of bits in the file
    shr rbx, 5          ; Bits / 32, amount of dwords required for prime
    mov rax, [array_size] ; Gets operations dwords size
    sub rax, rbx        ; Difference to move to right
    mov rbx, rax        ; Change register


    ; Calculation for bytes to load
    mov r12, [prime_bits]
    shr r12, 3              ; prime_bits/8

    ; Reads file 1 to prime1
    mov rdi, [fd1]
    lea rsi, [prime1+4*rbx]; 
    ;mov rsi, prime1
    mov rdx, r12
    mov rax, 0
    syscall 
    
    ; Reads file 2 to prime2
    mov rdi, [fd2]
    lea rsi, [prime2+4*rbx]
    mov rdx, r12
    mov rax, 0
    syscall 
    
    ; Flips de dwords
    mov r12, prime1
    call flip_array
    mov r12, prime2
    call flip_array
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    mov rdi, [fd2]
    mov rax, 3         ;sys_close
    syscall

    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret
generate_keys:
    ; keyn = p*q
    mov DWORD [mulA], prime1
    mov DWORD [mulB], prime2
    mov DWORD [mulC], keyn
    call big_mul

    call print_char

    ; p = p-1, and q = q-1
    mov r12, prime1
    call big_decrement
    mov r12, prime2
    call big_decrement

    call print_char

    ; keyl = p-1 * q-1
    mov DWORD [mulA], prime1
    mov DWORD [mulB], prime2
    mov DWORD [mulC], keyl
    call big_mul

    call print_char

    ; e calculation
    mov DWORD [coprE], keye
    mov DWORD [coprL], keyl
    call big_coprime

    call print_char

    ; d calculation
    mov DWORD [invE], keye
    mov DWORD [invL], keyl
    mov DWORD [invR], keyd
    call big_inverse

    call print_char

    ret
save_keys:

    ; Flips values of n, e, and d
    mov r12, keyn
    call flip_array
    mov r12, keye
    call flip_array
    mov r12, keyd
    call flip_array

    ; remove file first
    mov rdi, keynfile
    mov rax, 87 ; unlink
    syscall
    ; Opens n file
    mov rdi, keynfile
    mov rsi, 0102o      ;O_CREAT, man open
    mov rdx, 0666o      ;umode_t
    mov rax, 2          ; read mode
    syscall
    mov r12, rax
    ; Saves n value
    mov rdi, r12        ; file descriptor from previous opened file
    mov rsi, keyn+4     ; move start one because offset
    mov rdx, [array_size] ; size of operation
    dec rdx             ; size of actual key in dwords, one less
    shl rdx, 2          ; multiplies by 4 to get amount of bytes
    mov rax, 1          ; write mode
    syscall
    ; Close n file
    mov rdi, r12
    mov rax, 3         ;sys_close
    syscall

    ; remove file first
    mov rdi, keyefile
    mov rax, 87 ; unlink
    syscall
    ; Opens e file
    mov rdi, keyefile
    mov rsi, 0102o      ;O_CREAT, man open
    mov rdx, 0666o      ;umode_t
    mov rax, 2          ; read mode
    syscall
    mov r12, rax
    ; Saves e value
    mov rdi, rax        ; file descriptor from previous opened file
    mov rsi, keye+4     ; move start one because offset
    mov rdx, [array_size]; size of operation
    dec rdx             ; size of actual key in dwords, one less
    shl rdx, 2          ; multiplies by 4 to get amount of bytes
    mov rax, 1          ; write mode
    syscall
    ; Close e file
    mov rdi, r12
    mov rax, 3         ;sys_close
    syscall

    ; remove file first
    mov rdi, keydfile
    mov rax, 87 ; unlink
    syscall
    ; Opens d file
    mov rdi, keydfile
    mov rsi, 0102o      ;O_CREAT, man open
    mov rdx, 0666o      ;umode_t
    mov rax, 2          ; read mode
    syscall
    mov r12, rax
    ; Saves d value
    mov rdi, rax        ; file descriptor from previous opened file
    mov rsi, keyd+4     ; move start one because offset
    mov rdx, [array_size] ; size of operation
    dec rdx             ; size of actual key in dwords, one less
    shl rdx, 2          ; multiplies by 4 to get amount of bytes
    mov rax, 1          ; write mode
    syscall
    ; Close d file
    mov rdi, r12
    mov rax, 3         ;sys_close
    syscall



    ret

; Loads the required public key numbers from the specified files
; Loads message to encrypt, print and exit in length failure
; Move all the bytes to the right as they are loaded in the left side
; Encrypt the message
; Store the encrypted message/number in binary file
publickey_load:
    
    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Opens keyn
    mov rdi, keynfile
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; saves file descriptor
    
    ; Opens keye
    mov rdi, keyefile
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd2], rax

    ; Calculation for key loading offset
    xor rax, rax
    xor rbx, rbx
    mov rax, 1
    mov rbx, rax        ; Change register

    ; Calculation for bytes to load
    mov r12, [prime_bits]
    shr r12, 1          ; 4*prime_bits/8

    ; Reads keyn to vector
    mov rdi, [fd1]
    lea rsi, [keyn+4*rbx]; 
    mov rdx, r12
    mov rax, 0
    syscall 

    ; Reads keye to vector
    mov rdi, [fd2]
    lea rsi, [keye+4*rbx]
    mov rdx, r12
    mov rax, 0
    syscall 
    
    ; Flips the dwords
    mov r12, keyn
    call flip_array
    mov r12, keye
    call flip_array
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    mov rdi, [fd2]
    mov rax, 3         ;sys_close
    syscall

    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret
msg_load:
    
    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Opens msg
    mov rdi, msgfile
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; saves file descriptor


    ; Calculation for bytes to load
    mov r12, [array_size]
    dec r12
    shl r12, 2          ; 4(array_size-1)

    ; Reads msg to vector
    mov rdi, [fd1]
    lea rsi, [msg1+4] ;offset of one 
    mov rdx, r12
    mov rax, 0
    syscall 
    
    ; Checks if message length is valid

    shr r12, 1  ; r12 has 2(array_size-1), half of size of bytes

    cmp DWORD [msg1+r12+3], 0 ; 3 = 4-1, reduce one cause we need to look for one less to be sure
    jne msg_load_fail

    ; Moves message to position
    
    call fix_length

    ; Flips the dwords
    mov r12, msg1
    call flip_array
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall

    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret
msg_load_fail:

    ; Print error message
    mov rdi, 1  ; write in stdout
    mov rsi, errormsg
    mov rdx, lenerrormsg
    mov rax, 1
    syscall
    call print_newline
    ; Gets out of program
    mov rax, 60        ;system call number (sys_exit)
    syscall            ;call kernel

    ; Process is killed

fix_length:
    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Count amount of zeros at start of vector
    mov r12, [array_size]
    shl r12, 2              ; Bytes in the vector
    dec r12
    mov rbx, 0
fix_length_count:
    cmp     BYTE [msg1+r12], 0 ; keeps being zero
    jne     fix_length_count_end
    dec     r12
    inc     rbx
    jmp     fix_length_count
fix_length_count_end:
    
    ; Copies vector moved, rbx has amount of zeros to right

    ; rbx has index to copy to, starting in missing+4
    ; r12 has index to copy from, starting at 4
    mov rcx, [array_size]
    shl rcx, 2              ; Bytes in the vector
    add rbx, 4              ; increments rbx for offset
    mov r12, 4              ; Starting byte  
fix_length_copy:            ; moves to right
    cmp rbx, rcx            ; Compare to byte end
    je fix_length_copy_end              ; if right counter reached end
    mov al, BYTE [msg1+r12]             ; element in left
    mov BYTE [msg1+rbx], al         ; store it in right place
    mov BYTE [msg1+r12], 0           ; resets element in left
    inc rbx
    inc r12
    jmp fix_length_copy
fix_length_copy_end:


    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret

encrypt_message:
    mov QWORD [exp_modB], msg1
    mov QWORD [exp_modE], keye
    mov QWORD [exp_modM], keyn
    mov QWORD [exp_modR], msg2
    call big_modular_exponentiation
    ret
store_encryption:
    ; Flips values of msge
    mov r12, msg2
    call flip_array

    ; remove file first
    mov rdi, msgefile
    mov rax, 87 ; unlink
    syscall

    ; Opens msge file
    mov rdi, msgefile
    mov rsi, 0102o      ;O_CREAT, man open
    mov rdx, 0666o      ;umode_t
    mov rax, 2          ; read mode
    syscall
    mov r12, rax
    ; Saves msge value
    mov rdi, r12        ; file descriptor from previous opened file
    mov rsi, msg2+4     ; move start one because offset
    mov rdx, [array_size] ; size of operation
    dec rdx             ; size of actual key in dwords, one less
    shl rdx, 2          ; multiplies by 4 to get amount of bytes
    mov rax, 1          ; write mode
    syscall
    ; Close n file
    mov rdi, r12
    mov rax, 3         ;sys_close
    syscall

    ret

; Loads the required private key numbers from the specified files
; Loads encrypted message
; Decrypts message
; Stores decryption
privatekey_load:
    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Opens keyn
    mov rdi, keynfile
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; saves file descriptor
    
    ; Opens keyd
    mov rdi, keydfile
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd2], rax

    ; Calculation for key loading offset
    xor rax, rax
    xor rbx, rbx
    mov rax, 1
    mov rbx, rax        ; Change register

    ; Calculation for bytes to load
    mov r12, [prime_bits]
    shr r12, 1          ; 4*prime_bits/8

    ; Reads keyn to vector
    mov rdi, [fd1]
    lea rsi, [keyn+4*rbx]; 
    mov rdx, r12
    mov rax, 0
    syscall 

    ; Reads keye to vector
    mov rdi, [fd2]
    lea rsi, [keyd+4*rbx]
    mov rdx, r12
    mov rax, 0
    syscall 
    
    ; Flips the dwords
    mov r12, keyn
    call flip_array
    mov r12, keyd
    call flip_array
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    mov rdi, [fd2]
    mov rax, 3         ;sys_close
    syscall

    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret
msge_load:
    
    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Opens msge
    mov rdi, msgefile
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; saves file descriptor


    ; Calculate bytes
    mov r12, [array_size]
    dec r12
    shl r12, 2          ; 4(array_size-1)

    ; Reads msge to vector
    mov rdi, [fd1]
    lea rsi, [msg1+4] 
    mov rdx, r12
    mov rax, 0
    syscall 

    ; Flips the dwords
    mov r12, msg1
    call flip_array
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall

    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret
decrypt_message:
    
    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi
    mov QWORD [exp_modB], msg1
    mov QWORD [exp_modE], keyd
    mov QWORD [exp_modM], keyn
    mov QWORD [exp_modR], msg2
    call big_modular_exponentiation
    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx
    ret
    
store_decryption:
    ; loop over all bytes

    mov r12, msg2
    call flip_array
    mov r12, 4
store_decryption_loop:
    cmp BYTE [msg2+r12], 0
    jne store_decryption_end
    inc r12
    jmp store_decryption_loop
store_decryption_end:
    mov rax, [array_size]   ; size of vector in dwords
    shl rax, 2              ; bytes in all vector
    sub rax, r12            ; missing bytes, rax has amount to load
    mov rbx, rax
    
    ; remove file first
    mov rdi, msgdfile
    mov rax, 87 ; unlink
    syscall

    ; Opens msgd file
    mov rdi, msgdfile
    mov rsi, 0102o      ;O_CREAT, man open
    mov rdx, 0666o      ;umode_t
    mov rax, 2          ; read mode
    syscall
    mov rcx, rax        ; file descriptor to rcx
    ; Saves msgd value
    mov rdi, rcx        ; file descriptor from previous opened file
    lea rsi, [msg2+r12] ; move start one because offset
    mov rdx, rbx        ; multiplies by 4 to get amount of bytes
    mov rax, 1          ; write mode
    syscall
    ; Close msgd file
    mov rdi, rcx
    mov rax, 3          ;sys_close
    syscall

    ret

alert_encryption:

    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Print error message
    mov rdi, 1  ; write in stdout
    mov rsi, encryptionmsg
    mov rdx, lenencryptionmsg
    mov rax, 1
    syscall
    
    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret
alert_decryption:

    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Print error message
    mov rdi, 1  ; write in stdout
    mov rsi, decryptionmsg
    mov rdx, lendecryptionmsg
    mov rax, 1
    syscall
    
    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret
alert_key:

    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Print error message
    mov rdi, 1  ; write in stdout
    mov rsi, keymsg
    mov rdx, lenkeymsg
    mov rax, 1
    syscall
    
    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret
alert_all:

    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Print error message
    mov rdi, 1  ; write in stdout
    mov rsi, allmsg
    mov rdx, lenallmsg
    mov rax, 1
    syscall
    
    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret

alert_select:

    ; Framing
    mov rbp, rsp

    push    rbx                          ; saves rbx
    push    r12                          ; saves r12
    push    rax
    push    rsi
    push    rdi

    ; Print error message
    mov rdi, 1  ; write in stdout
    mov rsi, selectmsg
    mov rdx, lenselectmsg
    mov rax, 1
    syscall
    
    pop     rdi
    pop     rsi
    pop     rax
    pop     r12                         ; restores r12
    pop     rbx                         ; restores rbx

    ret