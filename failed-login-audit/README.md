# Failed Login Investigation

## Objective

A web server access log has been placed at `/workspace/data/access.log`.
Find the single IP address responsible for the most HTTP `401` (failed
login) responses, and write **only that IP address** to
`/workspace/output.txt`.

## Task

1. Inspect the log format — each line looks like:
   ```
   10.0.0.7 - - [10/Aug/2026:14:20:05 +0000] "POST /login HTTP/1.1" 401 128
   ```
2. Filter down to only the `401` lines.
3. Extract just the IP address (first field) from each matching line.
4. Count how often each IP appears, and find the one with the highest count.
5. Write that IP — and nothing else — to `/workspace/output.txt`.

## Hints

- `grep` can filter lines containing `401`.
- `awk '{print $1}'` pulls out the first whitespace-separated field of each line.
- `sort | uniq -c | sort -nr` is a classic combo for "count occurrences, most frequent first."
- `head -n1` gets you just the top result once sorted.
- Double-check your final file has no extra text, quotes, or trailing content —
  just the IP address itself.

## Expected Outcome

A file `/workspace/output.txt` containing exactly one IP address: the one
with the most `401` entries in the log.
