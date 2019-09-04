.data   
size:
        .word 128
base:
        .word 16
P:
        .word 0, 0x96bdbe0d
Q:
        .word 0, 0xed1b0de5

filename:
    .asciz      "/data/local/tmp/test.txt"
output_file:
    .asciz      "/data/local/tmp/out.txt"
decryption_key:
    .asciz      "/data/local/tmp/d_key.txt"
Handle:
    .skip 4
readBuffer:
    .skip 128

n:
        .word 0, 0, 0, 0
l:
        .word 0, 0, 0, 0
e:
        .word 0, 0, 0, 1
d:
        .word 0, 0, 0, 0
i:
        .word 0, 0, 0, 1
rsa_temp:
        .word 0, 1

gcd_temp1:
        .word 0, 0, 0, 0
gcd_temp2:
        .word 0, 0, 0, 0

msg:
        .word 0, 0, 0, 0        // to store message to encode or decodes


d_temp:
        .word 0, 0, 0, 0, 0, 0, 0, 0

num1:
        .word 0,0x012E,0x149E,0xA36F,0xE017,0x36F2,0xCDAE,0xD4FA,0x0ABA,0x908F,0x9370,0x1B5E,0x2483,0x803C,0xD295,0x3849//0, 0, 0x68, 0x6f6c6c65       // number
num2:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7       // number
num3:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0        // number
num4:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0        // number
num5:   
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0        // number


expmod_temp1:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // temp number
expmod_temp2:
        .word 0, 0, 0, 0, 0, 0, 0, 0       // temp number
expmod_temp3:
        .word 0, 0, 0, 0, 0, 0, 0, 0       // temp number
expmod_temp4:
        .word 0, 0, 0, 0, 0, 0, 0, 0       // temp number

var_u1:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // number
var_u3:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // number
var_v1:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // number
var_v3:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // number
var_q:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // number
var_t3:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // number
var_t1:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // number
modinv_temp1:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
modinv_temp2:
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

temp0:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // temp number
temp1:
        .word 0, 0, 0, 0, 0, 0, 0, 0        // temp number

string: .asciz "Argv: %s\n"
