# Sales Region Aggregation

## Objective
Determine which sales region has the highest total amount.

## Task
A pipe-delimited file at `/workspace/data/sales.csv` contains sales records with the header `name|region|amount|date`.

Sum the `amount` values for each `region` (skipping the header) and write **only the name of the region with the highest total** to `/workspace/output.txt` — exactly one word, no extra formatting.

## Hints
- The file uses `|` as a delimiter — many tools can specify a custom field separator.
- You will need to accumulate a sum per region and then find the maximum.
- Look at how to skip the first line of a file.

## Expected Outcome
`/workspace/output.txt` contains a single region name that matches the highest total. No extra spaces or additional lines.
