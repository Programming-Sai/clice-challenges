#!/usr/bin/env perl
# ubuntu:22.04 (hello-clice's base image) has no perl installed, so this
# checker should fail loudly and clearly when exec'd - not silently, and
# not with a stack trace that looks like a clice bug rather than a missing
# interpreter.
print "This should never run - perl isn't in the image.\n";
exit(0);