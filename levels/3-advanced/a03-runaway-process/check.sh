#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

nothing_cron() { ! grep -rqs '/usr/local/lib/.cache' /etc/cron.d /etc/crontab /var/spool/cron/crontabs; }
stays_gone() { sleep 6; process_absent kworker-u8 && process_absent dbus-helper; }

section "Investigation"
check_answer_is "name of the CPU burner" a03 burner kworker-u8
check_answer_is "name of the respawner" a03 parent dbus-helper
check_answer_is "path of the persistence file" a03 persistence /etc/cron.d/sysstat-collect

section "Eradication"
check "kworker-u8 is not running" process_absent kworker-u8
check "dbus-helper is not running" process_absent dbus-helper
check "no cron entry starts anything from /usr/local/lib/.cache" nothing_cron
check "payload files removed" test ! -e /usr/local/lib/.cache/kworker-u8 -a ! -e /usr/local/lib/.cache/dbus-helper
check "nothing respawns within 6 seconds" stays_gone

finish
