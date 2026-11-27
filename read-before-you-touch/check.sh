#!/usr/bin/env bash
# Verifies the whole "Read It Before You Touch It" handover: the repo, the server audit, the network fault.
# Runs as root inside the challenge container. Exit 0 only if everything passes.
if [ "$(id -u)" != 0 ]; then
  sudo -n true 2>/dev/null || { echo "  [FAIL] 2.3 engineer can no longer use sudo, so the server cannot be verified"; exit 1; }
  out=$(sudo -n env KENTE_CHECK_IGNORE_PORTS="${KENTE_CHECK_IGNORE_PORTS:-}" bash "$0" "$@" 2>/tmp/.kente_err); rc=$?
  printf '%s\n' "$out"; grep -v 'unable to resolve host' /tmp/.kente_err >&2; rm -f /tmp/.kente_err
  exit $rc
fi

REPO=/home/engineer/kente-repo
REMOTE=/srv/git/kente-app.git
SEED_MAIN=7e2bcebf146f6baeb3b6bed8620f3995801f5a8f
WIP=f3eda317030198f49696bc320336ae4c8ba5761c
G="git --git-dir=$REMOTE"
BASE=/usr/local/lib/kente/baseline.txt
LEAVER_KEY='AAAAC3NzaC1lZDI1NTE5AAAAIK7mR2eV0hH8vQ1xYpZ3sLw9uTq5nB4cJf6dXaGkO2yE'
FAILS=0; PASSES=0
ok()   { PASSES=$((PASSES+1)); printf '  [ ok ] %s\n' "$*"; }
bad()  { FAILS=$((FAILS+1));   printf '  [FAIL] %s\n' "$*"; }
chk()  { local d=$1; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }
sect() { printf '\n== %s ==\n' "$*"; }
show() { $G show "main:$1" 2>/dev/null; }
perm() { [ "$(stat -c '%U:%G %a' "$1" 2>/dev/null)" = "$2" ]; }

# make sure the "server" is in a booted state, then take a simulated reboot so that
# "stays that way after a reboot" and "starts automatically" are actually proven
/usr/local/lib/kente/first-run >/dev/null 2>&1
/usr/local/lib/kente/boot-sim >/dev/null 2>&1
sleep 2

# ------------------------------------------------------------------ REPO
sect "Repository and release"
if ! $G rev-parse -q --verify main >/dev/null; then bad "origin has no main branch"; fi
MAIN=$($G rev-parse main 2>/dev/null)
[ "$MAIN" != "$SEED_MAIN" ] && ok "main on origin has moved on from the inherited state" || bad "nothing has been pushed to origin/main yet"
chk "inherited history is intact (main was never rewritten)" $G merge-base --is-ancestor $SEED_MAIN main
chk "local checkout is on main and equals origin/main" test "$(git -C $REPO rev-parse HEAD 2>/dev/null)" = "$MAIN"
chk "working tree is clean (nothing uncommitted or unresolved)" test -z "$(git --no-optional-locks -C $REPO status --porcelain 2>/dev/null)"

# memo before the first change to inherited files
mapfile -t ALL < <($G rev-list --reverse --topo-order "$SEED_MAIN..main" 2>/dev/null)
INHERITED=$($G ls-tree -r --name-only $SEED_MAIN)
memo_idx=-1; change_idx=-1
for i in "${!ALL[@]}"; do
  c=${ALL[$i]}
  [ "$($G log -1 --format=%cn "$c")" = "Kofi Mensah" ] && continue
  files=$($G diff-tree -m -r --no-commit-id --name-only --root "$c" | sort -u)
  [ $memo_idx -lt 0 ] && echo "$files" | grep -qx 'MEMO.md' && memo_idx=$i
  [ $change_idx -lt 0 ] && echo "$files" | grep -Fxq -f <(echo "$INHERITED") && change_idx=$i
done
if [ $memo_idx -lt 0 ]; then bad "MEMO.md has not been committed to main"
elif [ $change_idx -ge 0 ] && [ $memo_idx -ge $change_idx ]; then bad "MEMO.md was committed AFTER a change to inherited files (it must come first)"
else ok "MEMO.md was committed before any change to inherited files"; fi
MEMO=$(show MEMO.md)
[ "$(echo "$MEMO" | wc -w)" -ge 100 ] && echo "$MEMO" | grep -q 'backup.sh' && echo "$MEMO" | grep -Eqi 'restart_app|sleep' \
  && ok "MEMO.md addresses both disputed scripts" || bad "MEMO.md is missing or does not discuss both disputed scripts (backup.sh and restart_app.sh)"

# the genuine bug
src=$(show scripts/backup.sh | sed -n 's/^SRC="\{0,1\}\([^"]*\)"\{0,1\}[[:space:]]*$/\1/p' | head -1)
[ "$src" = "/opt/kente-app/data" ] && ok "backup.sh now points at the real data directory" || bad "scripts/backup.sh still backs up the wrong place (SRC=$src)"
chk "the cause was fixed in the script, not hidden with a stand-in path (/var/opt/kente-app must not exist)" test ! -e /var/opt/kente-app
show scripts/backup.sh | grep -q 'tar ' && show scripts/backup.sh | grep -q '/backups' && ok "backup.sh still creates a tarball in /backups" || bad "backup.sh no longer creates a tarball in /backups"
good_bk=no; for f in /backups/*.tar.gz; do [ -e "$f" ] && tar -tzf "$f" 2>/dev/null | grep -q 'kente-app/data/catalog.json' && good_bk=yes; done
[ $good_bk = yes ] && ok "a real backup containing catalog.json exists in /backups (the fix is proven)" || bad "no backup containing the catalog exists in /backups yet - run the fixed script"

# the safeguard
sl=$(show scripts/restart_app.sh | sed -n 's/^[[:space:]]*sleep[[:space:]]\{1,\}\([0-9]\{1,\}\).*/\1/p' | head -1)
[ -n "$sl" ] && [ "$sl" -ge 7 ] && ok "restart_app.sh still waits for the health checker to re-stabilise" || bad "the restart safeguard in scripts/restart_app.sh was removed or shortened"
show scripts/restart_app.sh | grep -q 'systemctl restart kente-app' && ok "restart_app.sh still restarts the service" || bad "restart_app.sh no longer restarts the service"
SRVPY=$(show app/server.py)
echo "$SRVPY" | grep -q 'def upstream_ok' && echo "$SRVPY" | grep -q 'timeout=2' && echo "$SRVPY" | grep -q '"/health"' \
  && ok "the health check in app/server.py is intact" || bad "the health check in app/server.py was changed or disabled"
$G merge-base --is-ancestor $WIP main 2>/dev/null && bad "the untested WIP 'disable health check' snapshot was merged into main" || ok "the WIP snapshot is not on main"
$G ls-tree -r --name-only main | grep -q '^scratch/' && bad "scratch/ notes from the WIP branch ended up on main" || ok "main has no scratch/WIP files"

# the waiting work, merged cleanly
echo "$SRVPY" | grep -q '"/version"' && ok "the /version endpoint from feature/eta-display is on main" || bad "feature/eta-display (the /version endpoint) is not merged into main"
show config/app.conf | grep -q '^VERSION=1.2' && ok "config/app.conf is at VERSION=1.2" || bad "config/app.conf is not at VERSION=1.2"
README=$(show README.md)
echo "$README" | grep -q 'v1.1.1' && echo "$README" | grep -q 'v1.2' && ok "README keeps the v1.1.1 note AND gains the v1.2 note" || bad "README.md lost a release note (v1.1.1 from main or v1.2 from the feature branch)"
[ "$(show README.md | grep -c $'\r')" = 0 ] && ok "README.md has no stray Windows (CRLF) line endings" || bad "README.md still contains CRLF line endings"
[ -z "$($G grep -nE '^(<<<<<<< |>>>>>>> )' main -- 2>/dev/null)" ] && ok "no conflict markers committed" || bad "conflict markers are committed on main"
[ "$($G show main:.gitattributes 2>/dev/null)" = "$($G show $SEED_MAIN:.gitattributes)" ] && ok ".gitattributes untouched" || bad ".gitattributes was altered"
leak=$($G log -p "$SEED_MAIN..main" --format= -- . ':!*.md' 2>/dev/null | grep '^+' | grep -E 'BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}')
[ -z "$leak" ] && ok "no credentials were committed" || bad "a credential-looking string was committed to the repo"

sect "Handover document"
HAND=$(show HANDOVER.md)
[ -n "$HAND" ] && ok "HANDOVER.md exists on main" || bad "HANDOVER.md is missing from main"
echo "$HAND" | grep -q 'restart_app' && echo "$HAND" | grep -qi 'sleep' && ok "handover names the load-bearing restart workaround" || bad "handover does not warn about the restart_app.sh sleep"
echo "$HAND" | grep -qi 'CALMS' && echo "$HAND" | grep -qi 'DORA' && ok "handover covers CALMS and DORA" || bad "handover does not cover CALMS and DORA"
echo "$HAND" | grep -qi 'branch' && ok "handover documents a branching convention" || bad "handover has no branching convention"

# ------------------------------------------------------------------ SERVER
sect "1 Identity"
chk "1.1 hostname is kente-app-01 (checked after a simulated reboot)" test "$(head -1 /etc/hostname)" = "kente-app-01"

sect "2 Accounts and groups"
chk "2.1 kentesvc exists with shell /usr/sbin/nologin" test "$(getent passwd kentesvc | cut -d: -f7)" = "/usr/sbin/nologin"
members=$(getent group kente-ops | cut -d: -f4 | tr ',' '\n' | sort | paste -sd,)
[ "$members" = "engineer,kentesvc" ] && ok "2.2 kente-ops contains exactly engineer and kentesvc" || bad "2.2 kente-ops members are '$members' (expected engineer,kentesvc)"
chk "2.3 engineer may use sudo" bash -c "sudo -l -U engineer | grep -q 'NOPASSWD: ALL'"
{ getent passwd instructor; getent group instructor; id instructor
  sha256sum /etc/sudoers.d/10-instructor /etc/sudoers.d/90-cloud-init-users /etc/sudoers.d/10-engineer; } > /tmp/.inst.now 2>&1
chk "2.4 instructor is exactly as it was (account, groups, sudo files)" diff -q /tmp/.inst.now <(head -n -1 $BASE)
rm -f /tmp/.inst.now
st=$(passwd -S kmensah 2>/dev/null | awk '{print $2}')
chk "2.5 kmensah (left) exists with the password locked" test "$st" = "L" -o "$st" = "LK"
chk "2.5 kmensah's home folder and evidence were kept" test -f /home/kmensah/TODO.txt
chk "2.5 kmensah has no sudo rights" bash -c "sudo -l -U kmensah 2>&1 | grep -q 'not allowed'"
keyhits=$(grep -rl "$LEAVER_KEY" /home /root /var/lib/kentesvc /etc/ssh 2>/dev/null | head -1)
[ -z "$keyhits" ] && ok "2.5 no SSH key of kmensah can still log in" || bad "2.5 kmensah's SSH key is still present in $keyhits"
visudo -c >/dev/null 2>&1 && ok "2.6 sudoers syntax is valid" || bad "2.6 sudoers is invalid (visudo -c fails)"
extra=""
for f in /etc/sudoers.d/*; do
  [ "$(basename "$f")" = README ] && continue
  while read -r l; do case "$l" in ""|\#*) ;; engineer\ *|instructor\ *) ;; *) extra="$extra $(basename "$f")";; esac; done < "$f"
done
[ -z "$extra" ] && ok "2.6 only engineer and instructor have sudo rights" || bad "2.6 someone else still has sudo rights (see:$extra)"

sect "3 Files and permissions"
chk "3.1 /opt/kente-app is root:kente-ops 755"                   perm /opt/kente-app "root:kente-ops 755"
chk "3.2 /opt/kente-app/data is kentesvc:kente-ops 750"           perm /opt/kente-app/data "kentesvc:kente-ops 750"
chk "3.3 config/app.conf is root:kente-ops 640"                   perm /opt/kente-app/config/app.conf "root:kente-ops 640"
chk "3.4 /var/log/kente-app is kentesvc:kente-ops 750"            perm /var/log/kente-app "kentesvc:kente-ops 750"
chk "3.5 /backups is root:root 700"                               perm /backups "root:root 700"
chk "3.x nothing under the app, log or backup folders is world-writable" test -z "$(find /opt/kente-app /var/log/kente-app /backups -xdev ! -type l -perm -0002 2>/dev/null)"
chk "3.x the service account can still read its config, use its data and write its logs (least privilege, not too tight)" \
  setpriv --reuid=kentesvc --regid=kentesvc --init-groups sh -c 'cat /opt/kente-app/config/app.conf >/dev/null && ls /opt/kente-app/data >/dev/null && touch /var/log/kente-app/.w && rm /var/log/kente-app/.w'

sect "4 Services (after the simulated reboot)"
chk "4.1 kente-app is enabled"  systemctl is-enabled kente-app
chk "4.1 kente-app is running after the reboot" systemctl is-active kente-app
pid=$(cat /run/ksim/kente-app.service.pid 2>/dev/null)
chk "4.1 kente-app runs as kentesvc" test "$(ps -o user= -p "${pid:-0}" 2>/dev/null | tr -d ' ')" = "kentesvc"
chk "4.1 kente-app listens on 8080" bash -c "ss -ltnH | awk '{print \$4}' | grep -qE '(^|:)8080\$'"
chk "4.2 dispatch-stub is enabled" systemctl is-enabled dispatch-stub
chk "4.2 dispatch-stub is running" systemctl is-active dispatch-stub
chk "4.2 dispatch-stub listens on 127.0.0.1:9090 only" bash -c "ss -ltnH | awk '{print \$4}' | grep -qx '127.0.0.1:9090'"

sect "5 Network"
exposed=""
while read -r addr; do
  port=${addr##*:}; host=${addr%:*}
  case "$host" in 127.*|"[::1]"|::1) continue;; esac
  case " 22 8080 ${KENTE_CHECK_IGNORE_PORTS:-} " in *" $port "*) continue;; esac
  exposed="$exposed $addr"
done < <(ss -ltnH | awk '{print $4}')
[ -z "$exposed" ] && ok "5.1 only SSH and the app are reachable from outside" || bad "5.1 unexpected externally reachable listeners:$exposed"
python3 - <<'PY' >/dev/null 2>&1 && ok "5.2 ufw is enabled and allows exactly 22 and 8080" || bad "5.2 ufw is disabled or its rules differ from SSH (22) + app (8080) only"
import json,sys
s=json.load(open("/etc/ufw/sim-state.json"))
ports={r["to"].split("/")[0] for r in s["rules"] if r["action"]=="ALLOW"}
sys.exit(0 if s["enabled"] and ports=={"22","8080"} and len(s["rules"])==2 else 1)
PY
ip=$(getent hosts dispatch.kente.internal | awk '{print $1}' | head -1)
[ "$ip" = "127.0.0.1" ] && ok "5.3 dispatch.kente.internal resolves to 127.0.0.1" || bad "5.3 dispatch.kente.internal resolves to '${ip:-nothing}' (expected 127.0.0.1)"
grep -q '^UPSTREAM_URL=http://dispatch.kente.internal:9090/ping' /opt/kente-app/config/app.conf \
  && ok "5.3 the app still finds dispatch by NAME (the cause was fixed, not worked around)" || bad "5.3 UPSTREAM_URL in app.conf was changed - fix the name resolution instead"
grep -q 'timeout=2' /opt/kente-app/app/server.py && grep -q 'def upstream_ok' /opt/kente-app/app/server.py && ok "5.4 the deployed health check is intact" || bad "5.4 the deployed health check was altered"
code=$(curl -s -m 6 -o /tmp/.h -w '%{http_code}' http://localhost:8080/health); body=$(cat /tmp/.h 2>/dev/null); rm -f /tmp/.h
[ "$code" = "200" ] && [ "$body" = "ok" ] && ok "5.4 /health returns ok (HTTP 200)" || bad "5.4 /health returned HTTP $code '$body' (expected 200 ok)"

sect "6 Logs"
chk "6.x the current access.log still exists and kept its history" bash -c "[ -f /var/log/kente-app/access.log ] && [ \$(stat -c %s /var/log/kente-app/access.log) -ge $(tail -1 $BASE) ] && head -1 /var/log/kente-app/access.log | grep -q '^2026-11-02 07:00:00 127.0.0.1 GET /health 200'"
tail -1 /var/log/kente-app/access.log | grep -Eq '^[0-9-]+ [0-9:]+ [0-9.]+ GET /health 200 [0-9]+ms ok$' && ok "6.1 new requests are logged one line each in the policy format" || bad "6.1 the access log is not recording requests in the policy format"

printf '\n%d checks passed, %d failed\n' "$PASSES" "$FAILS"
[ "$FAILS" -eq 0 ]
