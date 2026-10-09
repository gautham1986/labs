#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

gw=$(ip route show default | awk '{print $3; exit}')
iface=$(ip route show default | awk '{print $5; exit}')
addr=$(ip -4 -o addr show dev "$iface" | awk '{print $4}' | cut -d/ -f1 | head -1)
dns=$(awk '$1 == "nameserver" {print $2; exit}' /etc/resolv.conf)
resolves_to() { [[ "$(getent ahostsv4 "$1" | awk 'NR == 1 {print $1}')" == "$2" ]]; }

section "What's listening"
check_answer "port mystery-svc listens on" i05 port
check_answer_is "process listening on TCP 8443" i05 proc legacy-proxy

section "Addressing"
check_answer_is "default gateway ($iface)" i05 gw "$gw"
check_answer_is "IPv4 address of $iface" i05 ip "$addr"
check_answer_is "first DNS nameserver" i05 dns "$dns"

section "Name resolution"
check "db.lab.internal resolves to 10.10.0.15" resolves_to db.lab.internal 10.10.0.15
check "cache.lab.internal resolves to 10.10.0.16" resolves_to cache.lab.internal 10.10.0.16

finish
