#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
F=/opt/lab/e03/requests-30d.csv
A=$LAB_ANSWERS/e03.env
[[ -f "$F" ]] || die "run lab start e03 first"

declare -A want got
while IFS='=' read -r k v; do want[$k]=$v; done < <(python3 "$LAB_DIR/answers.py" "$F")
if [[ -f "$A" ]]; then
  while IFS='=' read -r k v; do
    k=${k//[[:space:]]/}; v=${v//[[:space:]\"\']/}
    [[ -n "$k" && "$k" != \#* ]] && got[$k]=$v
  done < <(tr -d '\r' < "$A")
fi
num_ok() { is_number "${got[$1]:-x}" && within "${got[$1]}" "${want[$1]}" "$2"; }
str_ok() { [[ "${got[$1]:-}" == "${want[$1]}" ]]; }

[[ -f "$A" ]] || warn "write your answers to ~/answers/e03.env"
section "Availability SLO (99.9% / 30d)"
check "SLI_PERCENT" num_ok SLI_PERCENT 0.0011
check "BUDGET_TOTAL" num_ok BUDGET_TOTAL 1
check "BUDGET_REMAINING_PERCENT" num_ok BUDGET_REMAINING_PERCENT 0.11

section "Burn rate alerting"
check "BURN_RATE_1H" num_ok BURN_RATE_1H 0.011
check "BURN_RATE_5M" num_ok BURN_RATE_5M 0.011
check "PAGE" str_ok PAGE

section "Latency SLO"
check "LATENCY_SLI_PERCENT" num_ok LATENCY_SLI_PERCENT 0.011

finish
