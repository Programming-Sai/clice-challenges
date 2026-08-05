#!/bin/bash
# failed-login-audit checker
# Passes only if /workspace/output.txt exists and contains exactly the IP
# address responsible for the most HTTP 401 responses in access.log.
# Computed independently here rather than hardcoded, so this stays correct
# even if the dataset changes later.

log="/workspace/data/access.log"
target="/workspace/output.txt"

if [ ! -f "$log" ]; then
    echo "checker error: dataset missing at $log"
    exit 1
fi

if [ ! -f "$target" ]; then
    exit 1
fi

expected="$(grep ' 401 ' "$log" | awk '{print $1}' | sort | uniq -c | sort -nr | head -n1 | awk '{print $2}')"
actual="$(cat "$target" | tr -d '[:space:]')"

if [ "$actual" == "$expected" ]; then
    exit 0
fi

exit 1
