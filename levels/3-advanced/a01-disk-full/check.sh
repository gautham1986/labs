#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
V=/srv/a01 S=/srv/a01-sessions

use_below() { (( $(df --output=pcent "$1" | tail -1 | tr -dc 0-9) < $2 )); }
inodes_below() { (( $(df --output=ipcent "$1" | tail -1 | tr -dc 0-9) < $2 )); }
data_intact() { (cd "$V/app/data" && sha256sum --quiet -c "$LAB_VAR/a01/data.sha256"); }
no_deleted_open() { [[ -z "$(find /proc/[0-9]*/fd -lname "$V/*(deleted)" 2>/dev/null | head -1)" ]]; }
fresh_kept() { [[ "$(find "$S/sessions" -type f -mtime -1 | sort)" == "$(cat "$LAB_VAR/a01/fresh-sessions")" ]]; }
can_write() { touch "$S/sessions/lab-check" && rm -f "$S/sessions/lab-check"; }

findmnt "$V" >/dev/null || die "volumes not mounted - run: lab start a01"

section "Full volume ($V)"
check "usage below 50%" use_below "$V" 50
check "app/data untouched (checksums match)" data_intact
check "no deleted files held open on $V" no_deleted_open
check_answer_is "process that held the deleted file" a01 holder log-shipper

section "Inode exhaustion ($S)"
check "inode usage below 50%" inodes_below "$S" 50
check "new files can be created" can_write
check "sessions from the last day were kept" fresh_kept

finish
