#!/bin/bash
# git-merge-conflict checker
# Passes when: main contains a real merge commit joining both original tips,
# menu.txt has no conflict markers, the Coffee line carries both prices,
# and every non-conflicting change from both branches survived.

repo="/workspace/cafe"
fail() { echo "FAIL: $1"; exit 1; }

[ -d "$repo/.git" ] || fail "No git repository at $repo (don't delete or re-create it)"
cd "$repo" || fail "Cannot enter $repo"

[ ! -f .git/MERGE_HEAD ] || fail "Merge is still in progress - finish it with a commit"
[ -z "$(git ls-files -u)" ] || fail "There are still unresolved conflicted files"

branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
[ "$branch" = "main" ] || fail "You should be on main (currently on '$branch')"

main_sha="$(cat /opt/clice/main.sha 2>/dev/null)"
feat_sha="$(cat /opt/clice/feature.sha 2>/dev/null)"
git cat-file -e "${main_sha}^{commit}" 2>/dev/null \
    || fail "main's original commit is missing - don't re-create the repository"
git cat-file -e "${feat_sha}^{commit}" 2>/dev/null \
    || fail "The student-prices commit is missing - don't re-create the repository"

git merge-base --is-ancestor "$main_sha" HEAD 2>/dev/null \
    || fail "main's own work is not part of your history anymore"
git merge-base --is-ancestor "$feat_sha" HEAD 2>/dev/null \
    || fail "student-prices has not been merged into main yet"
[ "$(git rev-list --parents -n 1 HEAD | wc -w)" -eq 3 ] \
    || fail "HEAD is not a merge commit"

f="menu.txt"
[ -f "$f" ] || fail "menu.txt is missing"

if grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$f"; then
    fail "Conflict markers (<<<<<<<, =======, >>>>>>>) are still in menu.txt"
fi

coffee_count="$(grep -c '^Coffee' "$f")"
[ "$coffee_count" -eq 1 ] || fail "Expected exactly one Coffee line, found $coffee_count"
coffee="$(grep '^Coffee' "$f")"
echo "$coffee" | grep -q '15' || fail "Coffee line is missing the new price (15): '$coffee'"
echo "$coffee" | grep -q '12' || fail "Coffee line is missing the student price (12): '$coffee'"

grep -qx 'CAMPUS CAFE MENU'              "$f" || fail "The header line is missing or changed"
grep -qx 'Bread - GHS 5'                 "$f" || fail "The Bread line is missing or changed"
grep -qx 'Juice - GHS 6 (student price)' "$f" || fail "The student Juice price from student-prices was lost"
grep -qx 'Water - GHS 2'                 "$f" || fail "The Water line is missing or changed"
grep -qx 'Tea - GHS 8'                   "$f" || fail "The Tea line added on main was lost"
[ "$(wc -l < "$f" | tr -d ' ')" -eq 6 ]  || fail "menu.txt should have exactly 6 lines"

[ -z "$(git status --porcelain)" ] || fail "Working tree is not clean - run git status"

echo "PASS: both branches merged, conflict resolved, nothing lost"
exit 0
