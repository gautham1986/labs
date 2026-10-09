#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
PM=$LAB_ANSWERS/e01-postmortem.md

root_ok() { curl -fsS -m 5 localhost:8088/ | grep -q '"service": "shop"'; }
products_ok() { [[ "$(curl -s -m 8 -o /dev/null -w '%{http_code}' localhost:8088/products)" == 200 ]]; }
runs_as_shop() { local p; p=$(systemctl show -p MainPID --value shop); [[ $p -gt 0 && "$(ps -o user= -p "$p")" == shop ]]; }
upstream_is_shop() {  # nginx must point at shop's real listener
  nginx -T 2>/dev/null | grep -Eq 'server[[:space:]]+(127\.0\.0\.1|localhost):5050' 
}
pm_section() { grep -Eiq "^#+[[:space:]]*$1" "$PM"; }
pm_words() {  # 150+ words of your own: lines copied verbatim from the template don't count
  (( $(grep -vxFf "$LAB_ROOT/templates/postmortem.md" "$PM" | sed 's/<!--.*-->//g' | wc -w) >= 150 ))
}

section "Service restored"
check "GET :8088/ returns 200 from shop" root_ok
check "GET :8088/products returns 200" products_ok

section "Fixed properly"
check "shop.service is active" service_active shop
check "shop.service is enabled" service_enabled shop
check "shop runs as user shop" runs_as_shop
check "nginx -t passes" nginx -t
check "nginx upstream points at shop (127.0.0.1:5050)" upstream_is_shop

section "Postmortem (~/answers/e01-postmortem.md)"
if [[ -s "$PM" ]]; then
  for s in Summary Impact Timeline 'Root cause' Resolution 'Action items'; do
    check "has a '$s' section" pm_section "$s"
  done
  check "at least 150 words of your own (template text doesn't count)" pm_words
else
  check "postmortem written" false
fi

finish
