#!/bin/bash
clear
mkdir -p build
nasm -f elf64 -o build/rsa_ob.o -l build/rsa_l.lst rsa.asm -g -F dwarf
ld -s -m elf_x86_64 build/rsa_ob.o -o build/rsa_app -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
./build/rsa_app