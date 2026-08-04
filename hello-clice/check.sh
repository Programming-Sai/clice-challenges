#!/bin/bash
# hello-clice checker
# Passes only if /workspace/output.txt exists and contains exactly
# "Hello clice" (nothing more, nothing less, aside from a trailing newline
# which `echo "text" > file` naturally adds and read/strip-style
# comparisons should tolerate).

target="/workspace/output.txt"

if [ ! -f "$target" ]; then
    exit 1
fi

content="$(cat "$target")"

if [ "$content" == "Hello clice" ]; then
    exit 0
fi

exit 1