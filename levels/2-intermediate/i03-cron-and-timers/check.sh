#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
F=/etc/cron.d/i03-cleanup

# Does a cron line (fields 1-5) mean what we expect? Normalizes common equivalent spellings.
cron_line() {  # cron_line <file|-> <command> -> prints the matching line's 5 time fields (+ user if system)
  grep -v '^[[:space:]]*#' "$1" 2>/dev/null | grep -F "$2" | head -1
}
every_15() {
  local l; l=$(cron_line "$F" /opt/lab/i03/cleanup.sh)
  read -r m h dom mon dow user _ <<< "$l"
  [[ "$m" =~ ^(\*/15|0,15,30,45|0-59/15)$ && "$h $dom $mon $dow" == "* * * *" && "$user" == root ]]
}
weekday_0230() {
  local l; l=$(crontab -l -u "$LAB_USER" 2>/dev/null | grep -v '^[[:space:]]*#' | grep -F /opt/lab/i03/report.sh | head -1)
  read -r m h dom mon dow _ <<< "$l"
  [[ "$m" =~ ^0?30$ && "$h" =~ ^0?2$ && "$dom $mon" == "* *" && "${dow,,}" =~ ^(1-5|mon-fri|1,2,3,4,5)$ ]]
}
ends_with_newline() { [[ -s "$F" && -z "$(tail -c1 "$F")" ]]; }  # $(...) strips a trailing \n
timer_prop() { [[ "$(systemctl show -p "$1" --value i03-backup.timer)" =~ $2 ]]; }
svc_oneshot() { unit_prop_is i03-backup.service Type oneshot; }
ran_via_systemd() {
  [[ -s /var/backups/i03/last-run ]] &&
  journalctl -u i03-backup.service --no-pager -o cat | grep -q 'backup done'
}

section "cron"
check "cron daemon is running" service_active cron
check "/etc/cron.d/i03-cleanup runs cleanup.sh every 15 min as root" every_15
check "/etc/cron.d/i03-cleanup ends with a newline" ends_with_newline
check "your crontab runs report.sh at 02:30 Mon-Fri" weekday_0230

section "systemd timer"
check "i03-backup.service is Type=oneshot" svc_oneshot
check "i03-backup.timer is enabled" service_enabled i03-backup.timer
check "i03-backup.timer is active" service_active i03-backup.timer
check "timer fires hourly" timer_prop TimersCalendar 'OnCalendar=(hourly|\*-\*-\* \*:00:00)'
check "timer is Persistent" timer_prop Persistent yes
check "timer has RandomizedDelaySec=5min" timer_prop RandomizedDelayUSec '^5min$'
check "backup ran via systemd (journal has 'backup done')" ran_via_systemd

finish
