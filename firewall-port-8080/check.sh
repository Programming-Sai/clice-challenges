#!/bin/bash
xml="/etc/firewalld/zones/public.xml"
if command -v firewall-offline-cmd >/dev/null 2>&1; then if firewall-offline-cmd --zone=public --query-port=8080/tcp 2>/dev/null | grep -q "yes"; then echo "PASS: firewall-offline-cmd reports 8080/tcp is open"; exit 0; fi; fi
if command -v firewall-cmd >/dev/null 2>&1; then if firewall-cmd --permanent --query-port=8080/tcp 2>/dev/null | grep -q "yes"; then echo "PASS: firewall-cmd reports 8080/tcp is open"; exit 0; fi; fi
if [ -f "$xml" ]; then if grep -q 'port="8080"' "$xml" && grep -q 'protocol="tcp"' "$xml"; then echo "PASS: $xml contains port 8080/tcp"; cat "$xml"; exit 0; else echo "FAIL: $xml does not contain port 8080/tcp"; cat "$xml" 2>/dev/null; exit 1; fi; else echo "FAIL: $xml not found"; exit 1; fi
