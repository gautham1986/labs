#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit i03-backup.timer i03-backup.service
rm -rf /etc/cron.d/i03-cleanup /opt/lab/i03 /var/backups/i03
if crontab -l -u "$LAB_USER" 2>/dev/null | grep -q /opt/lab/i03; then
  crontab -l -u "$LAB_USER" | grep -v /opt/lab/i03 | crontab -u "$LAB_USER" -
fi
exit 0
