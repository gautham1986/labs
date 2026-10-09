#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
kill_spawned log-shipper; kill_by_name log-shipper
sleep 0.3
umount /srv/a01 2>/dev/null; umount /srv/a01-sessions 2>/dev/null
rmdir /srv/a01 /srv/a01-sessions 2>/dev/null
rm -rf /opt/lab/a01 "$LAB_VAR/a01"
exit 0
