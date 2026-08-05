#!/bin/bash
# hello-clice checker
# Passes only if /workspace/output.txt exists and contains exactly
# "Hello clice".

target="/workspace/output.txt"

if [ ! -f "$target" ]; then
    exit 1
fi

content="$(cat "$target")"

if [ "$content" == "Hello clice" ]; then
    exit 0
fi

exit 1