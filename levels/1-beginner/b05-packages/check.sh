#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q ' ok installed$'; }
held() { apt-mark showhold | grep -qx "$1"; }

section "Packages"
check "tree is installed" installed tree
check "ncdu is installed" installed ncdu
check "ncdu is on hold" held ncdu

section "Answers"
check_answer_is "package that owns /usr/bin/pgrep" b05 owner "$(dpkg -S /usr/bin/pgrep 2>/dev/null | cut -d: -f1)"
check_answer_is "installed bash version" b05 bashver "$(dpkg-query -W -f='${Version}' bash)"

finish
