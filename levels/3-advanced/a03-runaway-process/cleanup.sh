#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
rm -f /etc/cron.d/sysstat-collect
kill_spawned dbus-helper; kill_by_name dbus-helper; kill_by_name kworker-u8
rm -rf /usr/local/lib/.cache
exit 0
