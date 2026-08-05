#!/bin/bash
# ghost-service checker
# No workspace file is involved at all - every check here inspects LIVE
# process, user, and network state inside the running challenge container.
# This only works because verify() execs directly into the live container
# rather than checking a mounted volume snapshot.

fail=0
SERVICE_USER="svc-runner"
PORT=9000

# --- 1. the service user must exist and must not be root ---
if ! id "$SERVICE_USER" >/dev/null 2>&1; then
    echo "user '$SERVICE_USER' does not exist"
    fail=1
else
    uid="$(id -u "$SERVICE_USER")"
    if [ "$uid" == "0" ]; then
        echo "user '$SERVICE_USER' exists but has UID 0 (root) - it must be a non-root user"
        fail=1
    fi
fi

# --- 2. something must be listening on the expected port ---
listen_line="$(ss -tlnp 2>/dev/null | grep ":$PORT ")"
if [ -z "$listen_line" ]; then
    echo "nothing is listening on TCP port $PORT"
    fail=1
else
    pid="$(echo "$listen_line" | grep -oP 'pid=\K[0-9]+' | head -n1)"
    if [ -z "$pid" ] || [ ! -d "/proc/$pid" ]; then
        echo "found a listener on port $PORT but could not resolve its PID"
        fail=1
    else
        owner="$(stat -c '%U' "/proc/$pid" 2>/dev/null)"
        if [ "$owner" != "$SERVICE_USER" ]; then
            echo "port $PORT is being served by PID $pid, owned by '$owner' - expected '$SERVICE_USER'"
            fail=1
        fi
    fi
fi

# --- 3. the service must actually answer correctly ---
response="$(curl -s --max-time 3 "http://localhost:$PORT/health")"
if [ -z "$response" ]; then
    echo "GET /health on port $PORT returned nothing (service not responding)"
    fail=1
else
    if ! echo "$response" | grep -Eq '"status"[[:space:]]*:[[:space:]]*"ok"'; then
        echo "GET /health response did not contain \"status\": \"ok\" - got: $response"
        fail=1
    fi
    if ! echo "$response" | grep -Eq '"service"[[:space:]]*:[[:space:]]*"clice"'; then
        echo "GET /health response did not contain \"service\": \"clice\" - got: $response"
        fail=1
    fi
fi

exit $fail
