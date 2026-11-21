# Commit What Matters

## Objective

Make a proper commit: include the file that matters, and keep the noise out.

## Scenario

You've been working in `/workspace/project`. It's a git repo with one commit so far.
Since then you created two new files:

- `app.py` - your actual code. It belongs in the repo.
- `debug.log` - a throwaway log file. It does **not** belong in the repo, but you also don't want to delete it.

## Task

1. Go to `/workspace/project` (you start there).
2. Look at what git sees right now.
3. Commit `app.py`.
4. Tell git to ignore `debug.log`, and make sure that instruction is itself committed.
5. Finish with a clean working tree.

## Hints

- `git status` is your best friend. Run it often.
- `git add -A` stages *everything*, including things you may not want.
- Git reads ignore rules from a file called `.gitignore`.
- A `.gitignore` is just a file, so it needs to be committed too.

## Expected Outcome

- `app.py` is tracked and committed
- `debug.log` still exists on disk but is not tracked
- `.gitignore` is committed
- `git status` reports a clean working tree
