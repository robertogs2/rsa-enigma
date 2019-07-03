%include 'data.asm'
%include 'arithmetic.asm'
%include 'misc.asm'

section .text
global _start
_start:
    mov rbp, rsp; for correct debugging
    mov rax, 1

    call alert_select
    ;call do_key
    ;call do_encrypt
    ;call do_decrypt
    ;call do_all

    ; read from input to input variable
    
    mov rdi, 0          ; stdin
    mov rsi, input
    mov rdx, 1
    mov rax, 0          ; read call
    syscall

    ; Calculates keys
    cmp BYTE [input], 0x6b      ; compares with k
    je  do_key

    cmp BYTE [input], 0x65      ; compares with e
    je  do_encrypt

    cmp BYTE [input], 0x64      ; compares with d
    je do_decrypt

    cmp BYTE [input], 0x61      ; compares with a
    je do_all
    call end

    ret

do_key:
    call alert_key
    call prime_load
    call generate_keys
    call save_keys
    jmp end
    ;ret
do_encrypt:
    call alert_encryption
    call publickey_load
    call msg_load
    call encrypt_message
    call store_encryption
    jmp end
    ;ret
do_decrypt:
    call alert_decryption
    call privatekey_load
    call msge_load
    call decrypt_message
    call store_decryption
    jmp end
    ;ret
do_all:
    call alert_all
    call alert_key
    call prime_load
    call generate_keys
    call save_keys

    call alert_encryption
    call publickey_load
    call msg_load
    call encrypt_message
    call store_encryption

    call alert_decryption
    call privatekey_load
    call msge_load
    call decrypt_message
    call store_decryption

    jmp end
    ;ret
end:
    ; Gets out of program
    call print_newline
    mov rax, 60        ;system call number (sys_exit)
    syscall            ;call kernel