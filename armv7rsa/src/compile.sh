#!/bin/bash
arm-linux-gnueabi-gcc -static -march=armv7-a -mtune=cortex-a53 -mfloat-abi=softfp -mfpu=neon-vfpv4 rsa.s -o rsa
