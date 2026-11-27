# Read It Before You Touch It

> **Dispatch Manager:** "Our only ops person quit with zero handover. I've inherited a repo of scripts that
> route our drivers and a server nobody ever wrote anything down about. Some of it looks like junk to me, but
> I've seen someone rip out a 'junk' workaround before and it cost us three days of missed pickups - so figure
> out what's real before you change anything. We have a dispatch update going out Monday and it's blocked."

## What you are walking into

You are the new engineer at **Kente Courier Services**. You inherit:

- a Git repository of the departed engineer's scripts, checked out at `/workspace/kente-repo`
  (origin is `/srv/git/kente-app.git`; the work waiting for release lives on `feature/eta-display`),
- the application server itself, which in this exercise is **this same container**, and
- the server configuration policy: `/workspace/docs/SERVER-POLICY.md`.

Two pieces of the automation have already caused an argument: one person is sure a script is buggy, another insists
it is intentional. Somewhere across the repo and the server something is **genuinely broken**, and something is
stopping parts of the system talking to each other. Your job is not to rewrite what you find distasteful. It is to
prove, with evidence, what is wrong versus what only looks wrong - and fix the former without touching the latter.

## Before you touch anything

Write a short `MEMO.md` and push it to `origin/main` **before your first commit that changes an inherited file**:
what you believe each disputed piece of code does, whether it is safe to change or must be preserved (with
specific evidence: a comment, a log pattern, observed behaviour - not a guess), and what you expect the server
audit to find before you run it.

## The server

Evidence is yours to gather: the logs are in `/var/log/kente-app`, the service units in `/etc/systemd/system`,
and the policy tells you the required state. Record the command and output for every finding you fix.

Things to know about this training server:

- `systemctl`, `journalctl`, `hostnamectl`, `ufw` and `reboot` are **stand-ins** (a container has no systemd and cannot
  load kernel firewall rules). They behave like the real tools and keep real state, so use them as you would on a server.
  `reboot` simulates a reboot: services come back only if they are enabled, and hostname handling follows the
  real rules.
- Docker manages `/etc/hosts` and `/etc/hostname` here. Edit them **in place** (for example with `tee` or `>`);
  `sed -i` can fail with "Device or resource busy".
- Your remote refuses commits whose author email is not a company or GitHub no-reply address, and refuses
  non-fast-forward pushes. Fix problems the way you would on a shared repository.
- The scripts in `scripts/` are not marked executable in Git; the README's `sudo scripts/deploy.sh` is not
  guaranteed to work as written.

## How you are checked

Verification runs inside this container after your session and takes a few seconds. It simulates a reboot first, then checks
the repository on `origin`, every policy item, the network fix, and that every safeguard is still intact. Output
names the policy item that fails. It passes only when **everything** passes.

Not machine-graded here, but part of the real lab: the quality of your memo and handover, your two ideas for
preventing an undocumented handover, the AI-use and assumptions logs, and the live incident note.
