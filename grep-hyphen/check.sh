#!/bin/bash
target="/workspace/output.txt"
data="/workspace/data/options.txt"
if [ ! -f "$target" ]; then echo "FAIL: $target not found"; exit 1; fi
expected="$(grep -e "-k" "$data")"
actual="$(cat "$target")"
if [ "$actual" = "$expected" ] && [ "$(wc -l < "$target" | tr -d ' ')" -eq 1 ]; then echo "PASS: output matches expected line containing -k"; exit 0; else echo "FAIL: got '$actual', expected '$expected'"; exit 1; fi
