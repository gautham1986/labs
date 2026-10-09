#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

expires_on() {  # expires_on user YYYY-MM-DD  (shadow field 8 = days since epoch)
  local days; days=$(getent shadow "$1" | cut -d: -f8)
  [[ -n "$days" && "$days" == "$(( $(date -ud "$2" +%s) / 86400 ))" ]]
}
has_home() { local h; h=$(user_home "$1"); [[ -d "$h" && "$(stat -c %U "$h")" == "$1" ]]; }
system_uid() { local u; u=$(user_uid "$1"); [[ -n "$u" ]] && (( u < 1000 )); }
nologin_shell() { [[ "$(getent passwd "$1" | cut -d: -f7)" =~ ^/(usr/)?s?bin/(nologin|false)$ ]]; }

section "Groups"
check "group devops exists" group_exists devops
check "group auditors exists" group_exists auditors

section "Users"
for u in alice bob carol; do
  check "$u exists with a home directory" has_home "$u"
  check "$u has /bin/bash as shell" user_shell_is "$u" /bin/bash
done
check "alice is in devops" in_group alice devops
check "bob is in devops" in_group bob devops
check "carol is in auditors" in_group carol auditors
check "alice is in sudo" in_group alice sudo
check_not "bob is NOT in sudo" in_group bob sudo
check "bob's account expires on 2030-12-31" expires_on bob 2030-12-31

section "Service account"
check "appsvc exists with a system UID (< 1000)" system_uid appsvc
check "appsvc cannot log in (nologin shell)" nologin_shell appsvc
check "appsvc home is /var/lib/appsvc" test "$(user_home appsvc)" = /var/lib/appsvc

section "Shared directory"
check "/srv/devops exists" dir_exists /srv/devops
check "/srv/devops owned by root:devops" bash -c '[[ $(stat -c %U:%G /srv/devops) == root:devops ]]'
check "/srv/devops mode is 2770 (setgid, no access for others)" mode_is /srv/devops 2770

finish
