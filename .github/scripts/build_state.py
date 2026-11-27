#!/usr/bin/env python3
"""Decide which challenge images need (re)building, and record what was published.

A challenge is rebuilt when its folder changed since the commit its currently PUBLISHED image was built
from. That commit is kept in build-state.json on the `registry` branch, which is only updated after a
successful publish. Comparing against the last published state (rather than "this push's diff") means a
cancelled or failed run can never lose a change: the next run still sees the challenge as changed.

  plan   [--force-all]                     -> writes build / has_builds / publish to $GITHUB_OUTPUT
  record --built JSON --sha SHA --out FILE -> writes the new build-state.json
"""
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

STATE_REF = "origin/registry"
STATE_FILE = "build-state.json"


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True)


def challenge_folders():
    return sorted(p.parent.name for p in Path(".").glob("*/Dockerfile"))


def load_state():
    r = git("show", f"{STATE_REF}:{STATE_FILE}")
    if r.returncode != 0:
        return {}
    try:
        return dict(json.loads(r.stdout).get("challenges", {}))
    except (ValueError, AttributeError):
        return {}


def emit(name, value):
    line = f"{name}={value}\n"
    out = os.environ.get("GITHUB_OUTPUT")
    if out:
        with open(out, "a") as fh:
            fh.write(line)
    else:
        print(line, end="")


def plan(force_all):
    state, codes = load_state(), challenge_folders()
    build, skip = {}, {}
    for code in codes:
        rev = state.get(code)
        if force_all:
            build[code] = "rebuild-all flag is on"
        elif not rev:
            build[code] = "no published build recorded"
        elif git("cat-file", "-e", f"{rev}^{{commit}}").returncode != 0:
            build[code] = "recorded revision is not in this history"
        elif git("diff", "--quiet", rev, "HEAD", "--", code).returncode == 0:
            skip[code] = f"unchanged since {rev[:7]}"
        else:
            build[code] = f"changed since {rev[:7]}"
    stale = sorted(set(state) - set(codes))        # challenge folders that were deleted
    publish = bool(build) or bool(stale)

    lines = ["| Challenge | Action | Why |", "|---|---|---|"]
    lines += [f"| `{c}` | **build** | {w} |" for c, w in build.items()]
    lines += [f"| `{c}` | skip | {w} |" for c, w in skip.items()]
    lines += [f"| `{c}` | removed from registry | folder deleted |" for c in stale]
    table = "\n".join(lines)
    print(table)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a") as fh:
            fh.write("### Build plan\n\n" + table + "\n")

    emit("build", json.dumps(sorted(build)))
    emit("has_builds", "true" if build else "false")
    emit("publish", "true" if publish else "false")


def record(built, sha, out):
    state, codes = load_state(), set(challenge_folders())
    for code in built:
        state[code] = sha
    state = {c: r for c, r in state.items() if c in codes}
    Path(out).write_text(json.dumps({"challenges": state, "updated": sha}, indent=2, sort_keys=True) + "\n")
    print(f"Recorded {len(state)} challenges in {out}")


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("plan")
    p.add_argument("--force-all", action="store_true")
    r = sub.add_parser("record")
    r.add_argument("--built", required=True)
    r.add_argument("--sha", required=True)
    r.add_argument("--out", required=True)
    a = ap.parse_args()
    if a.cmd == "plan":
        plan(a.force_all)
    else:
        record(json.loads(a.built), a.sha, a.out)


if __name__ == "__main__":
    sys.exit(main())
