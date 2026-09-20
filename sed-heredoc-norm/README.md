# Config Sanitization

## Objective
Clean up the config file at `/workspace/data/app.conf`.

## Task
The file contains comment lines, blank lines, and a debug flag that is currently enabled.

Your goal is to leave the file in a clean state:
- No lines should start with `#`
- No empty lines should remain
- The setting `DEBUG_MODE` must be `false`, not `true`

Work directly on `/workspace/data/app.conf`. Inspect the file before and after to confirm your changes.

## Hints
- You can edit a file in place without opening an editor.
- Consider how to match lines that start with a specific character or are completely empty.
- A substitution can replace one string value with another.

## Expected Outcome
The file contains no comment or empty lines and includes `DEBUG_MODE=false`.
