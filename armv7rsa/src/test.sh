#!/bin/bash

adb push rsa /data/local/tmp/rsa
adb shell chmod +x /data/local/tmp/rsa
adb shell "echo \"SECRET\" > /data/local/tmp/test.txt"
adb shell /data/local/tmp/rsa -e
adb shell cat /data/local/tmp/test.txt
adb shell echo ""
adb shell cat /data/local/tmp/out.txt
adb shell echo ""
adb shell echo ""
adb shell /data/local/tmp/rsa -d
adb shell cat /data/local/tmp/out.txt
adb shell echo ""
adb pull /data/local/tmp/d_key.txt /tmp/x