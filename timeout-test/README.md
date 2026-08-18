# (Stress Test) Checker Timeout

Not a real challenge. Its checker deliberately hangs and floods stdout,
to confirm `checker_timeout` actually kills a runaway checker under real
adversarial conditions rather than just the clean cases already tested.

Do anything, submit, and confirm:
- The verdict comes back within `checker_timeout` seconds (default 20), not
  100,000 * 0.05s later.
- The result is a clean FAIL/ENVIRONMENT ERROR, not a hang or a crash.
- `docker ps -a` shows no leftover exec processes or zombie state afterward.

Remove this challenge from the registry once you're done with it - it's
a test fixture, not real content.
