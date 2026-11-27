#!/usr/bin/env python3
"""Generate the inherited access logs (format: date time client method path status ms note).
Deterministic. Patterns planted for the auditor to find:
  * /health is 200 until 2026-11-12 16:41 and 503 (2s timeout) on every check after it
  * after each app restart the health checker sees ~7s of 503 'connection refused' before 200
  * a few 2s-timeout false alarms before the 2026-11-03 hotfix
"""
import random, datetime as dt, sys
rnd = random.Random(7)
OUT = sys.argv[1] if len(sys.argv) > 1 else "/var/log/kente-app"
CLIENTS = ["154.160.12.8", "154.160.20.113", "41.66.4.77", "197.255.130.9", "154.161.3.52", "41.189.178.20",
           "102.176.64.31", "154.160.7.200", "197.251.33.140", "41.66.118.5", "154.160.25.64", "102.176.90.12"]
NOTE_REFUSED = "URLError: <urlopen_error_[Errno_111]_Connection_refused>"
NOTE_TIMEOUT = "URLError: <urlopen_error_timed_out>"
BREAK = dt.datetime(2026, 11, 12, 16, 41, 7)
RESTARTS = [dt.datetime(2026, 10, 24, 10, 15, 0), dt.datetime(2026, 11, 3, 11, 40, 0)]
FALSE_ALARMS = {dt.datetime(2026, 10, 31, 3, 12, 0), dt.datetime(2026, 11, 1, 19, 36, 0), dt.datetime(2026, 11, 2, 13, 48, 0)}

def fmt(ts, ip, path, status, ms, note):
    return f"{ts:%Y-%m-%d %H:%M:%S} {ip} GET {path} {status} {ms}ms {note}"

def build(start, end):
    ev = []
    t = start
    while t <= end:                                  # health checker, every 24 minutes
        if t >= BREAK:      ev.append((t, "127.0.0.1", "/health", 503, rnd.randint(2000, 2012), NOTE_TIMEOUT))
        elif t in FALSE_ALARMS: ev.append((t, "127.0.0.1", "/health", 503, 2001, NOTE_TIMEOUT))
        else:               ev.append((t, "127.0.0.1", "/health", 200, rnd.randint(4, 14), "ok"))
        t += dt.timedelta(minutes=24)
    for r in RESTARTS:                               # restart burst: ~7s until dispatch answers again
        if start <= r <= end:
            ev = [e for e in ev if abs((e[0] - r).total_seconds()) > 60]
            for s in range(7): ev.append((r + dt.timedelta(seconds=s), "127.0.0.1", "/health", 503, rnd.randint(2, 4), NOTE_REFUSED))
            ev.append((r + dt.timedelta(seconds=7), "127.0.0.1", "/health", 200, 6, "ok"))
    d = start.replace(hour=0, minute=0, second=0)
    while d <= end:                                  # storefront traffic
        for _ in range(rnd.randint(22, 48)):
            ts = d + dt.timedelta(seconds=rnd.randint(6 * 3600, 22 * 3600 + 1800))
            if start <= ts <= end:
                r = rnd.random()
                if r < .88:  ev.append((ts, rnd.choice(CLIENTS), "/", 200, rnd.randint(2, 9), "-"))
                elif r < .96: ev.append((ts, rnd.choice(CLIENTS), "/favicon.ico", 404, 1, "-"))
                else:         ev.append((ts, rnd.choice(CLIENTS), rnd.choice(["/admin", "/login", "/wp-login.php", "/.env"]), 404, 1, "-"))
        d += dt.timedelta(days=1)
    ev.sort(key=lambda e: e[0])
    return [fmt(*e) for e in ev]

old = build(dt.datetime(2026, 10, 22, 7, 0, 0), dt.datetime(2026, 11, 1, 23, 59, 0))
new = build(dt.datetime(2026, 11, 2, 7, 0, 0), dt.datetime(2026, 11, 25, 14, 58, 0))
new[0] = "2026-11-02 07:00:00 127.0.0.1 GET /health 200 4ms ok"
open(f"{OUT}/access.log.1", "w").write("\n".join(old) + "\n")
open(f"{OUT}/access.log", "w").write("\n".join(new) + "\n")
