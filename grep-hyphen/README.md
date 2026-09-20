# Hyphen Pattern Search

## Objective
Extract a single line from a file that contains a hyphen-prefixed pattern.

## Task
The file `/workspace/data/options.txt` lists one option per line. One of those lines contains the string `-k` (hyphen followed by `k`).

Find that line and write **only that line** to `/workspace/output.txt`.

Be careful — some search tools interpret leading hyphens as options rather than data.

## Hints
- A naive search for `-k` may be treated as an option rather than a pattern.
- Check your tool's manual for how to mark the end of options or specify a pattern explicitly.
- The output file must contain exactly one line.

## Expected Outcome
`/workspace/output.txt` contains exactly the line from the source file that includes `-k`.
