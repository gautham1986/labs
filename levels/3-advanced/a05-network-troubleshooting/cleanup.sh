#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit inventory-api.service
nft delete table inet legacy_filter 2>/dev/null
if grep -q 'api\.lab\.internal' /etc/hosts; then
  tmp=$(grep -v 'api\.lab\.internal' /etc/hosts); printf '%s\n' "$tmp" > /etc/hosts
fi
rm -rf /opt/lab/a05 /etc/lab/a05 "$LAB_VAR/a05-client.sha256"
exit 0
