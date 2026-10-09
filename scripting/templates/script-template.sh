#!/usr/bin/env bash
#
# NAME
#   script-template.sh - one line saying what this script does
#
# SYNOPSIS
#   script-template.sh [-n] [-v] [-o OUTDIR] FILE...
#
# DESCRIPTION
#   A starting point for production-grade bash scripts. Copy it, rename it, delete what you
#   don't need. Everything here exists because its absence has caused an outage somewhere.
#
# EXIT STATUS
#   0 success · 1 runtime error · 2 usage error
#
set -Eeuo pipefail          # exit on error, on unset vars, on failures inside pipes; ERR trap inherits
shopt -s inherit_errexit 2>/dev/null || true   # $(...) also honours -e (bash >= 4.4)
IFS=$'\n\t'                 # word splitting only on newlines/tabs, not spaces

readonly PROG=${0##*/}
readonly VERSION=0.1.0

# --- defaults (override with flags or environment) -------------------------------
OUTDIR=${OUTDIR:-/var/tmp}
DRY_RUN=0
VERBOSE=0

# --- logging: everything diagnostic goes to stderr, results go to stdout ------------
log()  { printf '%s %s: %s\n' "$(date '+%F %T')" "$PROG" "$*" >&2; }
info() { log "INFO $*"; }
warn() { log "WARN $*"; }
die()  { log "ERROR $*"; exit 1; }
debug() { (( VERBOSE )) && log "DEBUG $*"; return 0; }

usage() {
  cat <<EOF
Usage: $PROG [-n] [-v] [-o OUTDIR] FILE...

  -o OUTDIR   where to write results (default: $OUTDIR)
  -n          dry run: print what would happen, change nothing
  -v          verbose
  -h          show this help
  -V          show version
EOF
}

# run: execute a command, or just print it in dry-run mode
run() {
  if (( DRY_RUN )); then
    printf 'DRY-RUN:'; printf ' %q' "$@"; printf '\n'
  else
    debug "running: $*"
    "$@"
  fi
}

# --- cleanup: runs on every exit, including errors and Ctrl-C ----------------------
TMPDIR_WORK=""
cleanup() {
  local rc=$?
  [[ -n "$TMPDIR_WORK" && -d "$TMPDIR_WORK" ]] && rm -rf -- "$TMPDIR_WORK"
  exit "$rc"
}
on_error() { log "ERROR line $1: command '$2' exited with $3"; }
trap cleanup EXIT
trap 'on_error "$LINENO" "$BASH_COMMAND" "$?"' ERR
trap 'die "interrupted"' INT TERM

# --- argument parsing --------------------------------------------------------------
parse_args() {
  local opt
  while getopts ':o:nvhV' opt; do
    case $opt in
      o) OUTDIR=$OPTARG ;;
      n) DRY_RUN=1 ;;
      v) VERBOSE=1 ;;
      h) usage; exit 0 ;;
      V) echo "$PROG $VERSION"; exit 0 ;;
      :) usage >&2; die "option -$OPTARG needs an argument" ;;
      *) usage >&2; exit 2 ;;
    esac
  done
  shift $((OPTIND - 1))
  (( $# > 0 )) || { usage >&2; exit 2; }
  FILES=("$@")
}

# --- preflight checks: fail early with a clear message -----------------------------
preflight() {
  local cmd
  for cmd in tar gzip; do
    command -v "$cmd" >/dev/null || die "required command not found: $cmd"
  done
  [[ -d "$OUTDIR" ]] || die "output directory does not exist: $OUTDIR"
  [[ -w "$OUTDIR" ]] || die "output directory is not writable: $OUTDIR"
}

# --- the actual work ---------------------------------------------------------------
process_file() {
  local f=$1
  [[ -r "$f" ]] || { warn "skipping unreadable file: $f"; return 1; }
  info "processing $f"
  run cp -- "$f" "$TMPDIR_WORK/"
}

main() {
  parse_args "$@"
  preflight
  TMPDIR_WORK=$(mktemp -d)
  local f failed=0
  for f in "${FILES[@]}"; do
    process_file "$f" || failed=$((failed + 1))
  done
  run tar -czf "$OUTDIR/result-$(date +%Y%m%d-%H%M%S).tar.gz" -C "$TMPDIR_WORK" .
  (( failed == 0 )) || die "$failed file(s) failed"
  info "done"
}

# Only run main when executed, not when sourced (lets you unit-test functions)
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
