#!/bin/bash
target="/workspace/data/app.conf"
if [ ! -f "$target" ]; then echo "FAIL: $target missing"; exit 1; fi
if grep -q '^#' "$target"; then echo "FAIL: comment lines still present"; grep '^#' "$target"; exit 1; fi
if grep -q '^$' "$target"; then echo "FAIL: empty lines still present"; exit 1; fi
if ! grep -q 'DEBUG_MODE=false' "$target"; then echo "FAIL: DEBUG_MODE=false not found"; cat "$target"; exit 1; fi
if grep -q 'DEBUG_MODE=true' "$target"; then echo "FAIL: DEBUG_MODE=true still present"; exit 1; fi
echo "PASS: $target sanitized correctly"
exit 0
