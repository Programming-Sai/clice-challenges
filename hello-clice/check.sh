#!/bin/bash
# Deliberately hangs well past any reasonable CLICE_CHECKER_TIMEOUT,
# to confirm verify()'s thread.join(timeout=...) path recovers cleanly
# instead of the TUI freezing.
sleep 300
exit 0