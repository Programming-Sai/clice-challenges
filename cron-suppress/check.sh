#!/bin/bash
job="/workspace/job.sh"
if [ ! -f "$job" ]; then echo "FAIL: $job not found"; exit 1; fi
if [ ! -x "$job" ]; then echo "FAIL: $job is not executable"; ls -l "$job"; exit 1; fi
if ! grep -q "date" "$job"; then echo "FAIL: $job should contain date"; cat "$job"; exit 1; fi
# Check crontab via command OR spool file (daemon may not be running)
crontab_content="$(crontab -l 2>/dev/null)"
spool_content="$(cat /var/spool/cron/crontabs/root 2>/dev/null; cat /var/spool/cron/root 2>/dev/null; cat /var/spool/cron/crontabs/$(whoami) 2>/dev/null)"
combined="$crontab_content $spool_content"
if echo "$combined" | grep -qF -- "*/5 * * * * /workspace/job.sh >/dev/null 2>&1"; then echo "PASS: cron entry found"; exit 0; fi
if echo "$combined" | grep -q "job.sh.*>/dev/null.*2>&1"; then echo "PASS: cron entry found (variant)"; exit 0; fi
echo "FAIL: cron entry not found"
echo "crontab -l:"
echo "$crontab_content"
echo "spool:"
echo "$spool_content"
exit 1
