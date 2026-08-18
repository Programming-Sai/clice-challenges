#!/bin/bash
# Deliberately hangs well past any reasonable checker_timeout, and floods
# stdout while doing it, to stress-test both the timeout enforcement and
# the exec output-capture path under adversarial load.
for i in $(seq 1 100000); do
  echo "flooding output line $i - this checker should be killed before it ever gets here"
  sleep 0.05
done
exit 0
