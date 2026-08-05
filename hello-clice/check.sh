#!/usr/bin/env clice-fake-interpreter-xyz
# Unlike the earlier perl version, this actually checks output.txt's
# content - and uses a made-up interpreter name instead of guessing
# whether a real language happens to be preinstalled in the base image.
# No image will ever have a "clice-fake-interpreter-xyz" on its PATH,
# so this isolates the "interpreter genuinely missing" case cleanly:
# if this somehow still shows PASS, that's a real bug worth chasing.

target="/workspace/output.txt"
if [ ! -f "$target" ]; then
    exit 1
fi
content="$(cat "$target")"
if [ "$content" == "Hello clice" ]; then
    exit 0
fi
exit 1