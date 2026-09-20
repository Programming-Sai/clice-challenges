#!/bin/bash
if ! pgrep nginx >/dev/null 2>&1; then echo "Trying to start nginx..."; nginx 2>/dev/null || nginx -s reload 2>/dev/null || true; sleep 2; fi
target="/data/www/index.html"
if [ ! -f "$target" ]; then echo "FAIL: $target not found"; exit 1; fi
trimmed="$(head -n1 "$target" | tr -d '\r' | xargs)"
if [ "$trimmed" != "hello, clice" ]; then echo "FAIL: $target content is '$(cat "$target")', expected 'hello, clice'"; exit 1; fi
for i in 1 2 3 4 5; do resp="$(curl -s --max-time 3 http://localhost:8080/ 2>/dev/null)"; if [ -n "$resp" ]; then break; fi; sleep 1; done
if [ -z "$resp" ]; then echo "FAIL: curl http://localhost:8080/ returned empty"; ss -tlnp 2>/dev/null | grep 8080 || echo "No listener on 8080"; cat /var/log/nginx/error.log 2>/dev/null | tail -n 20; exit 1; fi
trimmed_resp="$(echo "$resp" | tr -d '\r' | xargs)"
if [ "$trimmed_resp" = "hello, clice" ]; then echo "PASS: http://localhost:8080/ returns hello, clice"; exit 0; else echo "FAIL: curl returned '$resp', expected 'hello, clice'"; exit 1; fi
