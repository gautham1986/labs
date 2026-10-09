# shellcheck shell=bash
# Assertion helpers for lab check scripts. Source after common.sh:
#   source "$LAB_ROOT/lib/common.sh"; source "$LAB_ROOT/lib/check.sh"
#
#   check "nginx is running" service_active nginx
#   check_answer "secret code is correct" b01 secret
#   finish
#
# Each check runs its predicate in a subshell with output hidden; only the
# verdict is printed. Set LAB_DEBUG=1 to see predicate output.

_PASS=0
_FAIL=0
_FAILED_DESCS=()

_run() {
  if [[ -n "${LAB_DEBUG:-}" ]]; then ( "$@" ); else ( "$@" ) >/dev/null 2>&1; fi
}

check() {  # check <description> <predicate> [args...]
  local desc=$1; shift
  if _run "$@"; then
    printf '  %s✔%s %s\n' "$C_GRN" "$C_RST" "$desc"; _PASS=$((_PASS + 1))
  else
    printf '  %s✘%s %s\n' "$C_RED" "$C_RST" "$desc"; _FAIL=$((_FAIL + 1)); _FAILED_DESCS+=("$desc")
  fi
}

check_not() {  # check_not <description> <predicate> [args...]  - passes when predicate fails
  local desc=$1; shift
  check "$desc" _negate "$@"
}
_negate() { ! "$@"; }

check_answer() {  # check_answer <description> <lab> <key>   (hashed answer from setup)
  local f; f=$(answer_path "$2" "$3")
  if [[ ! -s "$f" ]]; then
    check "$1 ${C_DIM}(write it to ~/answers/${f##*/})${C_RST}" false
  else
    check "$1" answer_matches "$2" "$3"
  fi
}

check_answer_is() {  # check_answer_is <description> <lab> <key> <expected>
  local f; f=$(answer_path "$2" "$3")
  if [[ ! -s "$f" ]]; then
    check "$1 ${C_DIM}(write it to ~/answers/${f##*/})${C_RST}" false
  else
    check "$1" answer_equals "$2" "$3" "$4"
  fi
}

section() { printf '\n%s%s%s\n' "$C_BLD" "$*" "$C_RST"; }

finish() {
  local total=$((_PASS + _FAIL))
  echo
  if (( _FAIL == 0 )); then
    printf '%s%sAll %d checks passed.%s\n' "$C_GRN" "$C_BLD" "$total" "$C_RST"
    return 0
  fi
  printf '%s%d/%d checks passed.%s Stuck? Try %slab hint %s%s\n' \
    "$C_YEL" "$_PASS" "$total" "$C_RST" "$C_BLD" "${LAB_ID:-<id>}" "$C_RST"
  return 1
}

# --- predicates ---------------------------------------------------------------
# All return 0/1 and print nothing useful; combine freely inside check.

file_exists()   { [[ -f "$1" ]]; }
dir_exists()    { [[ -d "$1" ]]; }
link_to()       { [[ -L "$1" && "$(readlink -f "$1")" == "$(readlink -f "$2")" ]]; }
is_executable() { [[ -x "$1" ]]; }
mode_is()       { [[ "$(stat -c %a "$1")" == "$2" ]]; }          # mode_is /x 750
owner_is()      { [[ "$(stat -c %U "$1")" == "$2" ]]; }          # owner_is /x root
group_is()      { [[ "$(stat -c %G "$1")" == "$2" ]]; }
file_contains() { grep -Eq -- "$2" "$1"; }                       # extended regex
file_lacks()    { ! grep -Eq -- "$2" "$1"; }
same_inode()    { [[ "$(stat -c %d:%i "$1")" == "$(stat -c %d:%i "$2")" ]]; }

user_exists()   { getent passwd "$1" >/dev/null; }
group_exists()  { getent group "$1" >/dev/null; }
in_group()      { id -nG "$1" 2>/dev/null | tr ' ' '\n' | grep -qx "$2"; }
user_shell_is() { [[ "$(getent passwd "$1" | cut -d: -f7)" == "$2" ]]; }
user_uid()      { getent passwd "$1" | cut -d: -f3; }

# by exact process name, ignoring zombies (a zombie is already dead)
process_running()  { ps -eo stat=,comm= | awk -v n="$1" '$1 !~ /^Z/ && $2 == n { f = 1 } END { exit !f }'; }
process_absent()   { ! process_running "$1"; }
pid_of()           { ps -eo pid=,stat=,comm= | awk -v n="$1" '$2 !~ /^Z/ && $3 == n { print $1; exit }'; }

service_active()   { systemctl is-active --quiet "$1"; }
service_enabled()  { systemctl is-enabled --quiet "$1"; }
unit_prop_is()     { [[ "$(systemctl show -p "$2" --value "$1")" == "$3" ]]; }  # unit_prop_is x.service User app

port_listening()   { ss -Hltn "sport = :$1" | grep -q .; }      # TCP listener on any address
port_closed()      { ! port_listening "$1"; }

http_code_is() {  # http_code_is <url> <code>
  [[ "$(curl -s -o /dev/null -m 5 -w '%{http_code}' "$1")" == "$2" ]]
}
http_ok()       { http_code_is "$1" 200; }
http_body_has() { curl -fsS -m 5 "$1" | grep -Eq -- "$2"; }      # http_body_has <url> <regex>
http_header_has() { curl -fsS -m 5 -D - -o /dev/null "$1" | grep -Eiq -- "$2"; }

cmd_output_is() {  # cmd_output_is <expected> <cmd...>
  local want=$1; shift
  [[ "$("$@" 2>/dev/null)" == "$want" ]]
}

within() {  # within <a> <b> <tolerance>  - numeric compare (fails on non-numbers)
  is_number "$1" && is_number "$2" || return 1
  awk -v a="$1" -v b="$2" -v t="$3" 'BEGIN { d = a - b; if (d < 0) d = -d; exit !(d <= t) }'
}

is_number() { [[ "$1" =~ ^[-+]?[0-9]*[.]?[0-9]+([eE][-+]?[0-9]+)?$ ]]; }
