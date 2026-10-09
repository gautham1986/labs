#!/usr/bin/env bash
# chaos.sh - apply one random fault to this box for a game day.
#   chaos.sh            apply a random fault (quietly)
#   chaos.sh FAULT      apply a specific fault
#   chaos.sh --list     list faults
#   chaos.sh --reveal   show what was applied
#   chaos.sh --undo     revert the last fault
# Target: a box running nginx on :80 (e.g. after project P1). Run as root. Never in production.
set -euo pipefail

STATE=/root/.gameday
mkdir -p "$STATE"
FAULTS=(disk-full nginx-stopped nginx-config dns-hosts firewall-drop cpu-hog perms-docroot)

[[ $EUID -eq 0 ]] || { echo "run as root" >&2; exit 1; }

apply() {
  case $1 in
    disk-full)     fallocate -l "$(( $(df --output=avail -B1 /var | tail -1) - 50 * 1024 * 1024 ))" /var/tmp/.cache-blob ;;
    nginx-stopped) systemctl stop nginx; systemctl mask nginx >/dev/null 2>&1 ;;
    nginx-config)  cp -a /etc/nginx/nginx.conf "$STATE/nginx.conf"; sed -i 's/worker_connections [0-9]*;/worker_connections 768/' /etc/nginx/nginx.conf; systemctl restart nginx || true ;;
    dns-hosts)     cp /etc/hosts "$STATE/hosts"; printf '%s\n' "$(cat /etc/hosts)" "10.255.255.1 $(hostname)" "10.255.255.1 lab node1 node2" > /etc/hosts ;;
    firewall-drop) nft add table inet chaos; nft add chain inet chaos input '{ type filter hook input priority -10; policy accept; }'; nft add rule inet chaos input tcp dport 80 drop ;;
    cpu-hog)       for _ in $(seq "$(nproc)"); do setsid nohup bash -c 'exec -a kthreadd-x yes > /dev/null' >/dev/null 2>&1 & done ;;
    perms-docroot) stat -c '%a' /var/www/html > "$STATE/docroot.mode"; chmod 700 /var/www/html ;;
    *) echo "unknown fault: $1" >&2; exit 2 ;;
  esac
  echo "$1" > "$STATE/applied"
}

undo() {
  local f; f=$(cat "$STATE/applied" 2>/dev/null) || { echo "nothing applied"; return; }
  case $f in
    disk-full)     rm -f /var/tmp/.cache-blob ;;
    nginx-stopped) systemctl unmask nginx >/dev/null 2>&1; systemctl start nginx ;;
    nginx-config)  cp -a "$STATE/nginx.conf" /etc/nginx/nginx.conf; systemctl restart nginx ;;
    dns-hosts)     cat "$STATE/hosts" > /etc/hosts ;;
    firewall-drop) nft delete table inet chaos ;;
    cpu-hog)       pkill -f kthreadd-x || true ;;
    perms-docroot) chmod "$(cat "$STATE/docroot.mode")" /var/www/html ;;
  esac
  rm -f "$STATE/applied"; echo "reverted: $f"
}

case ${1:-} in
  --list)   printf '%s\n' "${FAULTS[@]}" ;;
  --reveal) cat "$STATE/applied" 2>/dev/null || echo "nothing applied" ;;
  --undo)   undo ;;
  "")       [[ -f "$STATE/applied" ]] && { echo "a fault is already applied (--undo first)" >&2; exit 1; }
            apply "${FAULTS[RANDOM % ${#FAULTS[@]}]}"; echo "chaos applied. Good luck." ;;
  *)        apply "$1"; echo "applied $1" ;;
esac
