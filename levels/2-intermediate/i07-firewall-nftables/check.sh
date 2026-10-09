#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
CONF=/etc/nftables.conf
NS=i07client

input_chain() { nft list chain inet filter input 2>/dev/null; }
chain_has() { input_chain | grep -Eq "$1"; }
no_flush_ruleset() { ! grep -Eq '^[[:space:]]*flush[[:space:]]+ruleset' "$CONF"; }

# --- functional test from a fake client in a network namespace -------------------
ns_up() {
  ns_down
  ip netns add $NS || return 1
  ip link add i07h type veth peer name i07c || return 1
  ip link set i07c netns $NS
  ip addr add 192.168.77.1/24 dev i07h; ip addr add 10.199.0.1/24 dev i07h; ip link set i07h up
  ip -n $NS addr add 192.168.77.2/24 dev i07c; ip -n $NS addr add 10.199.0.2/24 dev i07c
  ip -n $NS link set i07c up; ip -n $NS link set lo up
  sleep 1
}
ns_down() { ip netns del $NS 2>/dev/null; ip link del i07h 2>/dev/null; return 0; }
from() {  # from <src-ip> <dst-ip> <port> -> connect succeeds?
  ip netns exec $NS timeout 3 bash -c "exec 3<>/dev/tcp/$2/$3" 2>/dev/null &&
  ip netns exec $NS timeout 3 nc -z -w 2 -s "$1" "$2" "$3"
}
blocked() { ! ip netns exec $NS timeout 3 nc -z -w 2 -s "$1" "$2" "$3"; }
ping_ok() { ip netns exec $NS ping -c1 -W2 192.168.77.1; }

section "Ruleset"
check "/etc/nftables.conf is valid (nft -c -f)" nft -c -f "$CONF"
check "/etc/nftables.conf doesn't 'flush ruleset'" no_flush_ruleset
check "table inet filter has an input chain with policy drop" chain_has 'policy drop'
check "established/related accepted" chain_has 'ct state (established,related|\{ ?established, related ?\}) accept'
check "invalid dropped" chain_has 'ct state invalid drop'
check "loopback accepted" chain_has 'iif(name)? "lo" accept'
check "SSH new connections are rate-limited" chain_has 'dport 22 .*limit rate'
check "nftables service enabled (persists across reboot)" service_enabled nftables

section "Live test from a fake client (network namespace)"
if ns_up; then
  check "ping from outside works" ping_ok
  check "outside -> 22 (ssh) allowed" from 192.168.77.2 192.168.77.1 22
  check "outside -> 8080 (web) allowed" from 192.168.77.2 192.168.77.1 8080
  check "outside -> 9100 (exporter) BLOCKED" blocked 192.168.77.2 192.168.77.1 9100
  check "outside -> 5432 (database) BLOCKED" blocked 192.168.77.2 192.168.77.1 5432
  check "monitoring (10.199.0.2) -> 9100 allowed" from 10.199.0.2 10.199.0.1 9100
  check "monitoring (10.199.0.2) -> 5432 BLOCKED" blocked 10.199.0.2 10.199.0.1 5432
else
  warn "could not create a network namespace here - live tests skipped"
fi
ns_down

finish
