#!/bin/bash
# Support both Ubuntu (/etc/bind) and openEuler (/etc/named.conf, /var/named)
zone_file=""
for f in /etc/bind/zones/app.local.db /var/named/app.local.db /etc/named/app.local.db; do if [ -f "$f" ]; then zone_file="$f"; break; fi; done
if [ -z "$zone_file" ]; then for f in $(find /etc -name "app.local.db" 2>/dev/null); do zone_file="$f"; break; done; fi
if [ -z "$zone_file" ] || [ ! -f "$zone_file" ]; then echo "FAIL: zone file app.local.db not found"; find /etc -name "*.db" 2>/dev/null | head; exit 1; fi
echo "Found zone file: $zone_file"
# Check BIND config contains zone
if ! grep -rq "app.local" /etc/bind/ 2>/dev/null && ! grep -rq "app.local" /etc/named* 2>/dev/null && ! grep -rq "app.local" /etc/ 2>/dev/null; then echo "FAIL: zone app.local not found in BIND config"; cat /etc/bind/named.conf.local 2>/dev/null; cat /etc/named.conf 2>/dev/null | head -n 40; exit 1; fi
if ! named-checkconf 2>&1; then echo "FAIL: named-checkconf failed"; named-checkconf 2>&1; exit 1; fi
if ! named-checkzone app.local "$zone_file" 2>&1; then echo "FAIL: named-checkzone failed"; named-checkzone app.local "$zone_file" 2>&1; exit 1; fi
if ! pgrep -x named >/dev/null 2>&1; then echo "Starting BIND..."; mkdir -p /var/run/named 2>/dev/null; chown bind:bind /var/run/named 2>/dev/null || chown named:named /var/run/named 2>/dev/null || true; /usr/sbin/named -u bind -g > /tmp/named.log 2>&1 & sleep 3; /usr/sbin/named -u named -g > /tmp/named.log 2>&1 & sleep 3; fi
for i in 1 2 3 4 5; do result="$(dig @127.0.0.1 www.app.local +short 2>/dev/null | tr -d '\r' | head -n1 | xargs)"; if [ -n "$result" ]; then break; fi; sleep 1; done
if [ "$result" = "192.168.1.100" ]; then echo "PASS: www.app.local resolves to 192.168.1.100"; exit 0; else echo "FAIL: dig returned '$result', expected '192.168.1.100'"; echo "Zone file:"; cat "$zone_file"; echo "named log:"; cat /tmp/named.log 2>/dev/null | tail -n 30; ss -tulpn 2>/dev/null | grep :53 || echo "no listener on 53"; exit 1; fi
