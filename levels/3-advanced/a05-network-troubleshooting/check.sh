#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

client_ok() { [[ "$(/opt/lab/a05/client.sh 2>/dev/null)" == "inventory: OK" ]]; }
client_unchanged() { sha256sum --quiet -c "$LAB_VAR/a05-client.sha256"; }
resolves_local() { [[ "$(getent ahostsv4 api.lab.internal | awk 'NR == 1 {print $1}')" == 127.0.0.1 ]]; }
api_local_only() { ss -Hltn 'sport = :9090' | awk '{print $4}' | grep -qx '127.0.0.1:9090' && ! ss -Hltn 'sport = :9090' | grep -q '0.0.0.0:9090'; }
no_drop_rule() { ! nft list ruleset | grep -Eq 'dport 9090 (drop|reject)'; }
rootcauses() { [[ $(grep -c '[[:alnum:]]' "$(answer_path a05 rootcauses)") -ge 3 ]]; }

section "Result"
check "client.sh prints 'inventory: OK'" client_ok
check "client.sh was not modified" client_unchanged

section "Fixed at the source"
check "api.lab.internal resolves to 127.0.0.1" resolves_local
check "API still listens on 127.0.0.1:9090 only" api_local_only
check "no firewall rule drops/rejects port 9090" no_drop_rule
check "inventory-api.service is active" service_active inventory-api

section "Write-up"
check "a05-rootcauses.txt lists at least 3 root causes" rootcauses

finish
