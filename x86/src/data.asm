; bits 64
; Change primebits and word_amount 
; if we use another amount of bits for primes, 
; change file to load primes too
; word_amount is 1+primebits/8, as 4*primebits is max size, 
; and div by 32 to get dwords
%define dwordbits 32
%define primebits 256
%define word_amount 1+primebits/8
%define path '/home/roberto/Documents/GitHub/RSAssembly/ROBERTO_GUTIERREZ_2016134351/'
%define keypath 'src/keys/'
%define msgpath 'src/messages/'
section .data
    
    ; File data, paths from home
    prime1file:                 db      path, keypath, 'prime256_1.bin', 0
    prime2file:                 db      path, keypath, 'prime256_2.bin', 0
    keynfile:                   db      path, keypath, 'keyn.bin', 0
    keyefile:                   db      path, keypath, 'keye.bin', 0
    keydfile:                   db      path, keypath, 'keyd.bin', 0
    msgfile:                    db      path, msgpath, 'msg.txt', 0
    msgefile:                   db      path, msgpath, 'msge.bin', 0
    msgdfile:                   db      path, msgpath, 'msgd.txt', 0
    
    ; General data
    dword_bits:                 dq      dwordbits
    prime_bits:                 dq      primebits
    array_size:                 dq      word_amount     ; 4096 bits, 512 bytes, 128 dwords
    base:                       dq      0x100000000     ; base for calculations
    max_32:                     dd       0xFFFFFFFF     ; base for calculations

    ; Printing
    testing:                    db      "*", 0 
    errormsg:                   db      'Length of message is too large, can', 96, 't encode message', 0xa
    lenerrormsg:                equ     $ - errormsg
    encryptionmsg:              db      0x0a, 'Starting encryption', 0xa
    lenencryptionmsg:           equ     $ - encryptionmsg
    decryptionmsg:              db      0x0a, 'Starting decryption', 0xa
    lendecryptionmsg:           equ     $ - decryptionmsg
    keymsg:                     db      0x0a, 'Starting key generation', 0xa
    lenkeymsg:                  equ     $ - keymsg
    allmsg:                     db      0x0a, 'Starting all', 0xa
    lenallmsg:                  equ     $ - allmsg
    selectmsg:                  db      0x0a, 'Plase insert one of the following options', 0xa, 'k : generate keys', 0xa, 'e : encrypt message', 0xa, 'd : decrypt message', 0xa, 'a : all of the above',0xa 
    lenselectmsg:               equ     $ - selectmsg

    input:                      db      0
    format_integer:             db      "%08X", 0
    format_new_line:            db      0x0a,0          ; New Line
section .bss

    ; Data for files and primes
    prime1:                     resd    word_amount
    prime2:                     resd    word_amount
    fd1:                        resq    1 ;prime1, keyn
    fd2:                        resq    1 ;prime2, keye, keyd

    ; Key data
    keyn:                       resd    word_amount
    keyl:                       resd    word_amount
    keye:                       resd    word_amount
    keyd:                       resd    word_amount

    msg1:                       resd    word_amount ; msg, msge
    msg2:                       resd    word_amount ; msge, msgd

    ; Data and vectors for arithmetic operations
    vectorA:                    resd    word_amount     ; test vector
    vectorB:                    resd    word_amount     ; test vector
    vectorC:                    resd    word_amount     ; test vector
    vectorD:                    resd    word_amount     ; test vector
    vectorE:                    resd    word_amount     ; test vector
    vectorF:                    resd    word_amount     ; test vector
    vectorG:                    resd    word_amount     ; test vector
    
    ; Pivoting vectors for operations
    pivot1:                     resd    word_amount     ;pivot vector used in add, sub
    pivot2:                     resd    word_amount     ;pivot vector
    pivot3:                     resd    word_amount     ;pivot vector
    pivot4:                     resd    word_amount     ;pivot vector
    pivot5:                     resd    word_amount     ;pivot vector
    pivot6:                     resd    word_amount     ;pivot vector
    ; Length variables
    lengthL:                    resd    1               
    ; Comparing variables
    comA:                       resd    1
    comB:                       resd    1
    comRes:                     resd    1
    ; Copying variables
    copA:                       resd    1
    copB:                       resd    1
    ; Add and sub data
    sumA:                       resd    1               
    sumB:                       resd    1               
    sumC:                       resd    1               
    subA:                       resd    1               
    subB:                       resd    1               
    subC:                       resd    1               
    carry:                      resd    1               ; memory section to store carry in case it
    old_carry:                  resd    1               ; memory section to store old carry in case it
    ; Multiply data
    mulA:                       resd    1
    mulB:                       resd    1
    mulC:                       resd    1
    mul_indexi:                 resd    1
    mul_indexj:                 resd    1
    mul_i:                      resd    1
    mul_j:                      resd    1
    low:                        resd    1               
    high:                       resd    1               
    ; Short Division data
    sDivA:                      resd    1
    sDivB:                      resd    1               ; Not a pointer
    sDivQ:                      resd    1
    sDivR:                      resd    1               ; Not a pointer
    ; Long Division data
    lDivA:                      resd    1
    lDivB:                      resd    1
    lDivQ:                      resd    1
    lDivR:                      resd    1
    div_n:                      resd    1
    div_l:                      resd    1     
    div_j:                      resd    1
    div_d:                      resq    1
    div_u:                      resd    word_amount
    div_v:                      resd    word_amount
    div_e:                      resq    1
    div_f:                      resq    1
    div_qt:                     resq    1
    div_rt:                     resq    1
    ; Modular exponentiation data
    exp_modB:                   resq    1
    exp_modE:                   resq    1
    exp_modM:                   resq    1
    exp_modR:                   resq    1
    ; Is zero check, pointer, constant, and result
    conA:                       resd    1
    conC:                       resd    1
    conR:                       resd    1
    ; Greatest common divisor data
    gcdA:                       resd    1
    gcdB:                       resd    1
    gcdR:                       resd    1   
    ; Inverse data
    invE:                       resd    1
    invL:                       resd    1
    invR:                       resd    1
    invIter:                    resd    1
    invInv:                     resd    word_amount
    invU1:                      resd    word_amount
    invU3:                      resd    word_amount
    invV1:                      resd    word_amount
    invV3:                      resd    word_amount
    invT1:                      resd    word_amount
    invT3:                      resd    word_amount
    invQ:                       resd    word_amount
    ; Coprime data
    coprL:                      resd    1
    coprE:                      resd    1
    ; Random data
    randS:                      resd    1
    randA:                      resd    1
