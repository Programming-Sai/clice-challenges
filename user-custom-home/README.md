# Custom User Setup

## Objective
Create a system user with specific attributes.

## Task
Create a user named `cliceuser` with:
- Home directory: `/opt/cliceuser`
- Login shell: `/bin/bash`
- UID: `1500`
- Primary group: `cliceuser` (also GID `1500`)

The home directory must exist and be owned by this user. The account does not need a password.

## Hints
- There is a single command that can set home, shell, and UID together — check its options for creating the home directory automatically.
- After creation, you can inspect the user’s entry and the home directory’s ownership.

## Expected Outcome
`getent passwd cliceuser` shows `cliceuser:x:1500:1500::/opt/cliceuser:/bin/bash` and `/opt/cliceuser` exists with correct ownership.
