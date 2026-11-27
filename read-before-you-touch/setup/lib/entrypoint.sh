#!/bin/bash
# runs as the image user (engineer); first-run needs root, which engineer has via sudo (policy 2.3)
sudo -n /usr/local/lib/kente/first-run >/dev/null 2>&1 || true
exec "$@"
