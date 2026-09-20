#!/bin/bash
target="/workspace/output.txt"
data="/workspace/data/sales.csv"
if [ ! -f "$target" ]; then echo "FAIL: $target not found"; exit 1; fi
expected="$(awk -F'|' 'NR>1 {sum[$2]+=$3} END {for (r in sum) print r, sum[r]}' "$data" | sort -k2 -nr | head -n1 | awk '{print $1}')"
actual="$(cat "$target" | tr -d '[:space:]')"
if [ "$actual" = "$expected" ]; then echo "PASS: region $actual matches expected $expected"; exit 0; else echo "FAIL: got '$actual', expected '$expected'"; cat -A "$target"; exit 1; fi
