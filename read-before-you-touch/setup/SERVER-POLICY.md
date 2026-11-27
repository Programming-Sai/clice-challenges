# Kente Courier Services: Server Configuration Policy

Applies to the **kente-app** application server. Owner: CTO, Kente Courier Services. Version 2.1, approved 2026-08-03.

This is how the application server must be configured. **Anything on the server that differs from this policy is a finding.**
Audit each item, record the command you ran and its output as evidence, and fix what is wrong using the least privilege
needed. Never "fix" something by widening permissions (for example `chmod 777`).

## 1. Identity
| # | Item | Required state |
|---|---|---|
| 1.1 | Hostname | `kente-app-01`, and it stays that way after a reboot |

## 2. Accounts and groups
| # | Item | Required state |
|---|---|---|
| 2.1 | Service account `kentesvc` | Exists, runs the app, cannot log in (shell `/usr/sbin/nologin`) |
| 2.2 | Operations group `kente-ops` | Members: current engineers and `kentesvc` only |
| 2.3 | Current engineer account `engineer` | Member of `kente-ops`; may use sudo |
| 2.4 | Assessor account `instructor` | Must stay exactly as it is (used for audits). Do not change or remove |
| 2.5 | Accounts of people who have left | Locked, removed from `kente-ops`, no sudo rights, no SSH keys that still let them in. Keep the home folder (it may be needed as evidence) |
| 2.6 | sudo rights | Only via files in `/etc/sudoers.d/` for current staff and `instructor`. Nobody else |

## 3. Files and permissions
| # | Path | Owner : group | Mode |
|---|---|---|---|
| 3.1 | `/opt/kente-app` | root : kente-ops | 755 |
| 3.2 | `/opt/kente-app/data` | kentesvc : kente-ops | 750 |
| 3.3 | `/opt/kente-app/config/app.conf` | root : kente-ops | 640 |
| 3.4 | `/var/log/kente-app` | kentesvc : kente-ops | 750 |
| 3.5 | `/backups` | root : root | 700 |

## 4. Services
| # | Service | Required state |
|---|---|---|
| 4.1 | `kente-app` | Running as `kentesvc`, enabled (starts automatically after a reboot), listening on port 8080 |
| 4.2 | `dispatch-stub` | Running and enabled. It stands in for the internal dispatch service |

## 5. Network
| # | Item | Required state |
|---|---|---|
| 5.1 | Inbound traffic | Only SSH (22) and the app (8080) are reachable from outside |
| 5.2 | Host firewall | `ufw` is the only host firewall in use, and it is enabled |
| 5.3 | Name resolution | `dispatch.kente.internal` resolves to `127.0.0.1` on this server |
| 5.4 | Health check | `curl http://localhost:8080/health` returns `ok` (HTTP 200) |

## 6. Logs
| # | Item | Required state |
|---|---|---|
| 6.1 | Access log | `/var/log/kente-app/access.log`, one line per request: date, time, client IP, method, path, status, duration, note |
| 6.2 | Retention | Logs older than 6 days may be deleted; the current day's log must never be deleted |

*Questions about this policy go to the CTO before you change anything.*
