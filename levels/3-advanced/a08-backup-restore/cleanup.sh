#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
rm -rf /srv/a08 /backup/a08 "$LAB_VAR/a08" /usr/local/sbin/a08-disaster
rm -f /usr/local/bin/snapshot-backup
userdel appuser >/dev/null 2>&1; groupdel appuser >/dev/null 2>&1
exit 0
