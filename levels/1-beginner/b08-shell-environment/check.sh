#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

# Run a command in a fresh interactive (-i) or login (-l) shell of the learner
ish() { su - "$LAB_USER" -s /bin/bash -c "bash -ic '$1' 2>/dev/null"; }
lsh() { su - "$LAB_USER" -s /bin/bash -c "bash -lc '$1' 2>/dev/null"; }

alias_ok()  { ish 'alias ports' | grep -Eq "ss -tulpn|ss -tlunp|ss -tunlp"; }
path_ok()   { [[ "$(lsh 'command -v labtool')" == /opt/tools/bin/labtool ]] || [[ "$(ish 'command -v labtool')" == /opt/tools/bin/labtool ]]; }
editor_ok() { [[ "$(lsh 'printenv EDITOR')" =~ (^|/)vim$ ]] || [[ "$(ish 'printenv EDITOR')" =~ (^|/)vim$ ]]; }
mkcd_ok() {
  local d; d=/tmp/b08-mkcd-$$
  [[ "$(ish "mkcd $d/x/y && pwd")" == "$d/x/y" ]]; local rc=$?
  rm -rf "$d"; return $rc
}

section "Dotfiles (checked in fresh shells)"
check "alias 'ports' runs ss -tulpn" alias_ok
check "labtool is on PATH (/opt/tools/bin)" path_ok
check "EDITOR=vim is exported" editor_ok
check "mkcd creates a directory and cds into it" mkcd_ok

section "Redirection"
check_answer "stdout of labtool saved to b08-out.txt" b08 out
check_answer "stderr of labtool saved to b08-err.txt" b08 err

finish
