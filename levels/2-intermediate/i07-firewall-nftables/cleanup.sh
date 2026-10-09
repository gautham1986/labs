#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
kill_spawned i07-web i07-exporter i07-db
kill_by_name fake-postgres
nft delete table inet filter 2>/dev/null
ip netns del i07client 2>/dev/null; ip link del i07h 2>/dev/null
if [[ -f /etc/nftables.conf.lab-orig ]]; then
  cp /etc/nftables.conf.lab-orig /etc/nftables.conf
fi
has_systemd && systemctl disable nftables >/dev/null 2>&1
exit 0
