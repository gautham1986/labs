#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
D=/opt/lab/e06/deploy.sh
LOG=$(mktemp -d)

live() { curl -fsS -m 2 localhost:8086/version 2>/dev/null; }

# deploy_under_load <release> <expect-rc: 0|fail> -> runs the deploy while hammering nginx
deploy_under_load() {
  local rel=$1 want=$2 rc codes bad
  ( while :; do curl -s -o /dev/null -m 2 -w '%{http_code}\n' localhost:8086/version; sleep 0.05; done ) > "$LOG/codes" 2>/dev/null &
  local hammer=$!
  sleep 0.5
  timeout 60 "$D" "$rel" > "$LOG/deploy-$rel.log" 2>&1; rc=$?
  sleep 1.5
  kill "$hammer" 2>/dev/null; wait "$hammer" 2>/dev/null
  codes=$(wc -l < "$LOG/codes"); bad=$(grep -vc '^200$' "$LOG/codes")
  echo "$rel: rc=$rc requests=$codes non-200=$bad" >> "$LOG/summary"
  if [[ $want == 0 ]]; then (( rc == 0 )) || return 1; else (( rc != 0 )) || return 1; fi
  (( codes > 20 && bad == 0 ))
}
one_color_up() {
  local n=0
  systemctl is-active --quiet app@blue && n=$((n + 1))
  systemctl is-active --quiet app@green && n=$((n + 1))
  (( n == 1 ))
}

section "Script"
check "$D exists and is executable" is_executable "$D"
check "nginx serves a version on :8086" bash -c "curl -fsS -m 2 localhost:8086/version"
is_executable "$D" || { finish; exit 1; }

start=$(live); target=v2; [[ "$start" == v2 ]] && target=v1
back=$start
section "Deploy $start -> $target under load"
check "deploy succeeds with zero non-200 responses" deploy_under_load "$target" 0
check "nginx now serves $target" cmd_output_is "$target" live
check "only one color is running afterwards" one_color_up

section "Deploy $target -> $back under load"
check "deploy succeeds with zero non-200 responses" deploy_under_load "$back" 0
check "nginx now serves $back" cmd_output_is "$back" live

section "Broken release v3-broken"
check "deploy is rejected (non-zero exit) with zero non-200 responses" deploy_under_load v3-broken fail
check "traffic stayed on $back" cmd_output_is "$back" live
check "the broken color was stopped" one_color_up

echo; sed 's/^/  /' "$LOG/summary" 2>/dev/null
echo "  (deploy logs: $LOG)"
finish
