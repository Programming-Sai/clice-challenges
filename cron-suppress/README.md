# Scheduled Task with Suppressed Output

## Objective
Set up a recurring scheduled task that runs quietly.

## Task
1. Create an executable script at `/workspace/job.sh` that appends the current date/time to `/workspace/log.txt`.
2. Schedule it to run **every 5 minutes** via `cron`. The job must discard both standard output and standard error so it generates no mail.

Add the schedule without interactively editing the crontab.

## Hints
- The script needs to be executable to run from cron.
- A cron schedule has five time fields followed by a command — research the pattern for “every 5 minutes”.
- Redirecting both output streams is the key to suppressing mail.

## Expected Outcome
- `/workspace/job.sh` is executable and appends a date to the log.
- The cron table contains an entry that runs every 5 minutes and redirects output to `/dev/null`.
