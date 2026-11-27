#!/bin/bash
/usr/local/lib/kente/first-run >/dev/null 2>&1 || true
exec "$@"
