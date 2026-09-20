# Numeric Permission 764

## Objective
A file at `/workspace/output.txt` must exist and have permissions `764`.

## Task
Create the file `/workspace/output.txt` (any content is fine) and configure its permissions so that:
- Owner can read, write, and execute (`rwx`)
- Group can read and write (`rw-`)
- Others can read only (`r--`)

In octal, this combination is `764`. The checker will verify the numeric mode.

## Hints
- `stat` can show the current numeric mode of a file.
- Permissions can be set using either symbolic (`u=rwx,g=rw,o=r`) or numeric (`764`) forms.

## Expected Outcome
`/workspace/output.txt` exists and its mode is `764`. Verify your work with `stat`.
