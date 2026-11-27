# clice-challenges
## CI: what gets built

On every push to `main`, CI rebuilds **only the challenges that changed** since their last *published* build. Nothing
is rebuilt when nothing changed. "Last published" is recorded in `build-state.json` on the `registry` branch, so a
cancelled or failed run never loses a change: the next run picks it up again.

To rebuild **everything** (for example after changing the workflow, the base image, or a shared script), turn the flag on:

| How | When to use it |
|---|---|
| Put `[rebuild-all]` in the head commit message of a push | one-off, from a normal push |
| Actions tab, "Build and Push Challenge Images", Run workflow, tick **rebuild_all** | one-off, manual |
| Repository variable `CLICE_REBUILD_ALL` = `true` (Settings, Secrets and variables, Variables) | keep it on until you delete the variable |

The flag is **off by default**. A new challenge folder is always built (it has no published build yet), and a deleted
folder is removed from the registry. The first run after adopting this change builds everything once, to create
`build-state.json`. The "Plan which challenges to build" step shows a table of what will be built and why.
`fresh_build` (ignore the Docker cache) still applies, but only to the challenges that are built.
