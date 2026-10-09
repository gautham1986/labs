# shellcheck shell=bash
# Tiny test harness for the scripting track. Sourced by each exercise's test.sh.
#
#   SCRIPT=greet.sh                       # file under $WORK_DIR being tested
#   source "$LAB_ROOT/scripting/lib/testlib.sh"
#   t "greets by name"   '[[ "$(S Ada)" == "Hello, Ada!" ]]'
#   t "no args -> rc 2"  'S; [[ $? -eq 2 ]]'
#   done_testing
#
# S runs your script (with bash, 10 s timeout). Each test body runs in a subshell; output hidden.
# Set TEST_DEBUG=1 to see it.

: "${WORK_DIR:?WORK_DIR not set - run this through: lab check <id>}"
: "${SCRIPT:?set SCRIPT before sourcing testlib}"
LAB_ROOT=${LAB_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
SCRIPT_PATH="$WORK_DIR/$SCRIPT"
# shellcheck disable=SC2034  # used by test.sh files
FIXTURES="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)/fixtures"
TMPD=$(mktemp -d)
trap 'rm -rf "$TMPD"' EXIT

# (underscore names so tests can freely use short variable names like R, G, F)
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then _G=$'\e[32m' _R=$'\e[31m' _D=$'\e[2m' _B=$'\e[1m' _N=$'\e[0m'; else _G='' _R='' _D='' _B='' _N=''; fi
_P=0 _F=0

S() { timeout "${S_TIMEOUT:-10}" bash "$SCRIPT_PATH" "$@"; }

t() {  # t <description> <bash code>
  local desc=$1 code=$2 ok
  if [[ -n "${TEST_DEBUG:-}" ]]; then (cd "$TMPD" && eval "$code"); ok=$?
  else (cd "$TMPD" && eval "$code") >/dev/null 2>&1; ok=$?; fi
  if (( ok == 0 )); then printf '  %s✔%s %s\n' "$_G" "$_N" "$desc"; _P=$((_P + 1))
  else printf '  %s✘%s %s\n' "$_R" "$_N" "$desc"; _F=$((_F + 1)); fi
}

section() { printf '\n%s%s%s\n' "$_B" "$*" "$_N"; }

# common checks every exercise gets
basic_checks() {
  section "Basics"
  t "$SCRIPT exists in ${WORK_DIR/#$HOME/\~}" '[[ -f "$SCRIPT_PATH" ]]'
  t "has a bash shebang" 'head -1 "$SCRIPT_PATH" | grep -Eq "^#!(/usr)?/bin/(env )?bash"'
  t "is valid bash syntax (bash -n)" 'bash -n "$SCRIPT_PATH"'
  if command -v shellcheck >/dev/null; then
    t "passes shellcheck (warnings and errors)" 'shellcheck -S warning "$SCRIPT_PATH"'
  fi
}

done_testing() {
  local total=$((_P + _F))
  echo
  if (( _F == 0 )); then printf '%s%sAll %d tests passed.%s\n' "$_G" "$_B" "$total" "$_N"; return 0; fi
  printf '%s/%s tests passed. %sDebug a failing test: TEST_DEBUG=1 lab check %s%s\n' "$_P" "$total" "$_D" "${LAB_ID:-<id>}" "$_N"
  return 1
}
