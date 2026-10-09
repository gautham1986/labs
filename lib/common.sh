# shellcheck shell=bash
# Shared helpers for lab setup/check/cleanup scripts. Source it, don't execute it:
#   source "$LAB_ROOT/lib/common.sh"
#
# The `lab` command exports these before calling a lab script (as root):
#   LAB_ROOT     repo root (default: /lab)
#   LAB_ANSWERS  where the learner writes answer files (default: $LAB_ROOT/workspace/answers)
#   LAB_USER     the learner's login name (default: learner)

LAB_ROOT="${LAB_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LAB_ANSWERS="${LAB_ANSWERS:-$LAB_ROOT/workspace/answers}"
LAB_USER="${LAB_USER:-${SUDO_USER:-learner}}"
LAB_VAR="/var/lib/lab"           # root-only scenario state (expected answers are stored hashed)
LAB_RUN="/run/lab"               # pidfiles of background scenario processes
export LAB_ROOT LAB_ANSWERS LAB_USER

# shellcheck disable=SC2034  # palette for all lab scripts; not every color is used everywhere
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_RED=$'\e[31m' C_GRN=$'\e[32m' C_YEL=$'\e[33m' C_BLU=$'\e[34m' C_DIM=$'\e[2m' C_BLD=$'\e[1m' C_RST=$'\e[0m'
else
  C_RED='' C_GRN='' C_YEL='' C_BLU='' C_DIM='' C_BLD='' C_RST=''
fi

info() { printf '%s==>%s %s\n' "$C_BLU" "$C_RST" "$*"; }
warn() { printf '%s[warn]%s %s\n' "$C_YEL" "$C_RST" "$*" >&2; }
die()  { printf '%s[error]%s %s\n' "$C_RED" "$C_RST" "$*" >&2; exit 1; }

need_root() { [[ $EUID -eq 0 ]] || die "must run as root - use: lab start <id>"; }

has_systemd() { [[ -d /run/systemd/system ]]; }
need_systemd() {
  has_systemd || die "this lab needs systemd as PID 1. Use the Docker env (make up) or a VM - see README.md"
}

need_cmd() {
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "missing command '$c' - install it (or run env/bootstrap.sh)"
  done
}

# device-mapper (needed by LVM) is in the running kernel?
has_dm() { grep -qw device-mapper /proc/devices 2>/dev/null || grep -qw device-mapper /proc/misc 2>/dev/null; }

is_container() {
  [[ -f /.dockerenv || -f /run/.containerenv ]] && return 0
  command -v systemd-detect-virt >/dev/null 2>&1 && systemd-detect-virt -cq
}

user_home() { getent passwd "${1:-$LAB_USER}" | cut -d: -f6; }

# Run a command as the learner (login shell, so ~/.profile etc. are read)
as_user() { su - "$LAB_USER" -s /bin/bash -c "$*"; }

# Make sure the answers dir exists and belongs to the learner
prepare_answers() {
  mkdir -p "$LAB_ANSWERS"
  chown "$LAB_USER": "$LAB_ANSWERS" 2>/dev/null || true
}

# --- expected answers --------------------------------------------------------
# Answers generated at setup time are stored as sha256 hashes so that peeking
# at /var/lib/lab doesn't give them away.

normalize() {  # strip CRs, surrounding spaces, leading/trailing blank lines; always end with \n
  awk '{ sub(/\r$/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); l[NR] = $0 }
       END { s = 1; while (s <= NR && l[s] == "") s++
             e = NR; while (e >= s && l[e] == "") e--
             for (i = s; i <= e; i++) print l[i] }'
}
_hash() { normalize | sha256sum | cut -d' ' -f1; }

expect_set() {  # expect_set <lab> <key> <value>
  install -d -m 0700 "$LAB_VAR/$1"
  printf '%s\n' "$3" | _hash > "$LAB_VAR/$1/$2.sha256"
}

answer_path() { printf '%s/%s-%s.txt' "$LAB_ANSWERS" "$1" "$2"; }

answer_matches() {  # answer_matches <lab> <key>  (compares answer file to stored hash)
  local f; f=$(answer_path "$1" "$2")
  [[ -s "$f" && -f "$LAB_VAR/$1/$2.sha256" ]] || return 1
  [[ "$(_hash < "$f")" == "$(cat "$LAB_VAR/$1/$2.sha256")" ]]
}

answer_equals() {  # answer_equals <lab> <key> <expected-value> (expected computed at check time)
  local f; f=$(answer_path "$1" "$2")
  [[ -s "$f" ]] || return 1
  [[ "$(normalize < "$f")" == "$(printf '%s\n' "$3" | normalize)" ]]
}

# --- background scenario processes ------------------------------------------

spawn() {  # spawn <name> <cmd> [args...]  -> detached process, pid in /run/lab/<name>.pid
  local name=$1; shift
  mkdir -p "$LAB_RUN"
  # setsid detaches from the terminal (so no SIGHUP on logout). Deliberately no nohup:
  # it would make the process ignore SIGHUP, and some labs need SIGHUP to work.
  setsid "$@" >/dev/null 2>&1 < /dev/null &
  echo $! > "$LAB_RUN/$name.pid"
}

spawned_pid() { cat "$LAB_RUN/$1.pid" 2>/dev/null; }

kill_spawned() {  # kill_spawned <name>...
  local n pid
  for n in "$@"; do
    pid=$(spawned_pid "$n") || continue
    [[ -n "$pid" ]] && kill -9 "$pid" 2>/dev/null
    rm -f "$LAB_RUN/$n.pid"
  done
  return 0
}

# Copy a binary under a new name, so `ps`/`top`/`pgrep` show that name.
clone_bin() {  # clone_bin <source-cmd> <dest-path>
  install -D -m 0755 "$(command -v "$1")" "$2"
}

# Install the shared tiny HTTP service (lib/labapp.py) somewhere a service user can run it
install_app() { install -D -m 0755 "$LAB_ROOT/lib/labapp.py" "$1"; }

# Some containers/kernels have IPv6 disabled; nginx's stock default site (listen [::]:80) then
# refuses to start. Disable that site so it doesn't masquerade as a lab fault.
nginx_ipv6_guard() {
  python3 -c 'import socket; socket.socket(socket.AF_INET6).bind(("::", 0))' 2>/dev/null && return 0
  if [[ -e /etc/nginx/sites-enabled/default ]] && grep -q '\[::\]' /etc/nginx/sites-enabled/default; then
    rm -f /etc/nginx/sites-enabled/default
    warn "IPv6 is unavailable here, so nginx's default site (listen [::]:80) can't start - disabled it."
  fi
}

kill_by_name() { pkill -9 -x "$1" 2>/dev/null; return 0; }

# Remove a systemd unit created by a lab (stop, disable, delete, reload)
remove_unit() {
  local u
  for u in "$@"; do
    if has_systemd; then
      systemctl disable --now "$u" >/dev/null 2>&1 || true
      systemctl reset-failed "$u" >/dev/null 2>&1 || true
    fi
    rm -rf "/etc/systemd/system/$u" "/etc/systemd/system/$u.d"
  done
  has_systemd && systemctl daemon-reload
  return 0
}

wait_for() {  # wait_for <seconds> <cmd...> - poll until cmd succeeds
  local deadline=$((SECONDS + $1)); shift
  until "$@" >/dev/null 2>&1; do
    (( SECONDS >= deadline )) && return 1
    sleep 0.5
  done
}

lab_done_msg() {
  printf '\n%sScenario ready.%s Read the brief with %slab show %s%s, then %slab check %s%s when done.\n' \
    "$C_GRN" "$C_RST" "$C_BLD" "$1" "$C_RST" "$C_BLD" "$1" "$C_RST"
}
