#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
kill_spawned mystery-svc legacy-proxy
kill_by_name mystery-svc; kill_by_name legacy-proxy
sed -i '/lab\.internal/d' /etc/hosts 2>/dev/null || true   # /etc/hosts is a bind mount in Docker: sed -i may fail
if grep -q 'lab\.internal' /etc/hosts; then
  tmp=$(grep -v 'lab\.internal' /etc/hosts); printf '%s\n' "$tmp" > /etc/hosts
fi
exit 0
