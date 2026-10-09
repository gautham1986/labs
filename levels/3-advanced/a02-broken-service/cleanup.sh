#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
kill_spawned old-payments; kill_by_name old-payments
remove_unit payments.service
rm -rf /opt/lab/a02 /etc/payments
userdel payments >/dev/null 2>&1; groupdel payments >/dev/null 2>&1
exit 0
