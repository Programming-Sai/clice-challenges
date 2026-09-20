#!/bin/bash
target="/workspace/output.txt"
if [ ! -f "$target" ]; then echo "FAIL: $target does not exist"; exit 1; fi
mode="$(stat -c '%a' "$target" 2>/dev/null)"
if [ "$mode" = "764" ]; then echo "PASS: $target has mode 764"; exit 0; else echo "FAIL: $target has mode $mode, expected 764"; exit 1; fi
