#!/bin/bash
# git-selective-commit checker
# Passes when: app.py is committed, debug.log is NOT tracked but still on disk,
# a committed .gitignore is what ignores it, and the working tree is clean.

repo="/workspace/project"
fail() { echo "FAIL: $1"; exit 1; }

[ -d "$repo/.git" ] || fail "No git repository at $repo (don't delete or re-create it)"
cd "$repo" || fail "Cannot enter $repo"

base="$(cat /opt/clice/base.sha 2>/dev/null)"
git cat-file -e "${base}^{commit}" 2>/dev/null \
    || fail "The original starting commit is missing - don't re-create the repository"
git merge-base --is-ancestor "$base" HEAD 2>/dev/null \
    || fail "Your history no longer includes the starting commit"
[ "$(git rev-parse HEAD)" != "$base" ] \
    || fail "No new commit yet - you haven't committed anything"

tracked="$(git ls-tree -r --name-only HEAD)"

echo "$tracked" | grep -qx "app.py" \
    || fail "app.py is not committed yet"
if echo "$tracked" | grep -qx "debug.log"; then
    fail "debug.log is committed - it should be ignored, not tracked (hint: git rm --cached)"
fi
echo "$tracked" | grep -qx ".gitignore" \
    || fail "There is no committed .gitignore file"
[ -f debug.log ] \
    || fail "debug.log was deleted - it should stay on disk, just be ignored"

source_file="$(git check-ignore -v debug.log 2>/dev/null | cut -d: -f1)"
[ "$source_file" = ".gitignore" ] \
    || fail "debug.log is not being ignored by .gitignore"

[ -z "$(git status --porcelain)" ] \
    || fail "Working tree is not clean - run git status to see what is left"

echo "PASS: app.py committed, debug.log ignored and kept, tree is clean"
exit 0
