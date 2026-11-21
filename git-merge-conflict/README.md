# Resolve the Merge Conflict

## Objective

Two people edited the same menu. Combine their work without losing either.

## Scenario

`/workspace/cafe` is a repo for a campus cafe's `menu.txt`. Two branches have diverged:

- `main` raised the coffee price and added a new item.
- `student-prices` added discounted prices.

Both changed the **same Coffee line**, so git can't decide for you.

## Task

1. Go to `/workspace/cafe` (you start there) and make sure you're on `main`.
2. Merge `student-prices` into `main`.
3. Git will stop with a conflict. Open `menu.txt` and resolve it.
   - The Coffee line must show **both** the new regular price (15) and the student price (12).
   - Every other change from both branches must be kept.
4. Finish the merge with a commit.

## Hints

- `git status` tells you which files are in conflict.
- Conflicted sections look like `<<<<<<<`, `=======`, `>>>>>>>`. Those markers must not remain in the final file.
- You can edit files with `sed`, `echo`, or `cat > file`. (There's no interactive editor in this container.)
- After editing, tell git the conflict is resolved with `git add`, then run `git commit`. The default merge message is used automatically.
- Nothing here can hurt you. If it goes wrong, `git merge --abort` puts you back at the start.

## Expected Outcome

- `main` has a merge commit joining both branches
- `menu.txt` has 6 lines, no conflict markers, and a Coffee line mentioning both prices
- `git status` is clean
