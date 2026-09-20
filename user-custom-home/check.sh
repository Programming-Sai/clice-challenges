#!/bin/bash
if ! getent passwd cliceuser >/dev/null 2>&1; then echo "FAIL: user cliceuser does not exist"; exit 1; fi
entry="$(getent passwd cliceuser)"
echo "Found: $entry"
if ! echo "$entry" | grep -q "^cliceuser:x:1500:1500::/opt/cliceuser:/bin/bash$"; then echo "FAIL: passwd entry does not match expected cliceuser:x:1500:1500::/opt/cliceuser:/bin/bash"; echo "Got: $entry"; exit 1; fi
if [ ! -d "/opt/cliceuser" ]; then echo "FAIL: home directory /opt/cliceuser does not exist"; exit 1; fi
owner="$(stat -c '%U' /opt/cliceuser 2>/dev/null)"
gid="$(stat -c '%g' /opt/cliceuser 2>/dev/null)"
if [ "$owner" != "cliceuser" ]; then echo "FAIL: /opt/cliceuser owned by $owner, expected cliceuser"; exit 1; fi
if [ "$gid" != "1500" ]; then echo "FAIL: /opt/cliceuser GID $gid, expected 1500"; exit 1; fi
echo "PASS: user cliceuser correctly configured"
exit 0
