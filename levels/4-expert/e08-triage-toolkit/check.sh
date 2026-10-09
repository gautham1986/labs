#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
T=/usr/local/bin/triage
OUT=$(mktemp -d)
WORK=$(mktemp -d)
trap 'rm -rf "$OUT" "$WORK"' EXIT
FILES=(system.txt cpu-mem.txt disk.txt processes.txt network.txt services.txt logs.txt summary.txt)

help_ok() { "$T" -h | grep -qi usage; }
badopt_rc2() { "$T" -Z >/dev/null 2>&1; [[ $? -eq 2 ]]; }
BUNDLE=""
run_ok() {
  local start=$SECONDS out
  out=$(timeout 30 "$T" -o "$OUT") || return 1
  (( SECONDS - start < 30 )) || return 1
  BUNDLE=$(tail -1 <<< "$out")
  echo "$BUNDLE" > "$WORK/bundle"
}
bundle_named() {
  local b; b=$(cat "$WORK/bundle")
  [[ -f "$b" && "$(basename "$b")" =~ ^triage-$(hostname)-[0-9]{8}-[0-9]{6}\.tar\.gz$ && "$(dirname "$b")" == "$OUT" ]]
}
extract() { local b; b=$(cat "$WORK/bundle"); tar -xzf "$b" -C "$WORK" && ls -d "$WORK"/triage-*/ >/dev/null; }
has_file() { local d; d=$(ls -d "$WORK"/triage-*/ | head -1); [[ -s "$d/$1" ]]; }
summary_has() { grep -Eq "$1" "$WORK"/triage-*/summary.txt; }
no_temp_left() { [[ -z "$(find /tmp /var/tmp -maxdepth 1 -newer "$WORK" -type d -name 'tmp.*' ! -path "$WORK" ! -path "$OUT" 2>/dev/null)" ]]; }
lint_ok() { command -v shellcheck >/dev/null || return 0; shellcheck -S warning "$T"; }

section "CLI"
check "$T exists and is executable" is_executable "$T"
is_executable "$T" || { finish; exit 1; }
check "-h prints usage and exits 0" help_ok
check "unknown option exits 2" badopt_rc2
check "passes shellcheck" lint_ok

section "Bundle"
touch "$WORK"
check "triage -o DIR runs in < 30s and exits 0" run_ok
check "last line is the bundle path: DIR/triage-<host>-<YYYYmmdd-HHMMSS>.tar.gz" bundle_named
check "bundle is a valid tar.gz with a triage-*/ directory" extract
for f in "${FILES[@]}"; do check "contains non-empty $f" has_file "$f"; done
check "temp directory cleaned up" no_temp_left

section "Findings (summary.txt)"
check "flags /srv/e08 as >= 90% full" summary_has 'WARN.*/srv/e08'
check "flags the failed unit lab-e08-broken.service" summary_has 'WARN.*lab-e08-broken'

finish
