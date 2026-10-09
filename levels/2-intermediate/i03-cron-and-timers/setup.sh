#!/usr/bin/env bash
# i03 setup: three job scripts; scheduling is up to you
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd crontab
prepare_answers
bash "$LAB_DIR/cleanup.sh"
systemctl enable --now cron >/dev/null 2>&1

mkdir -p /opt/lab/i03
cat > /opt/lab/i03/cleanup.sh <<'S'
#!/usr/bin/env bash
# delete temp files older than a day
find /tmp -maxdepth 1 -name 'i03-*' -mtime +1 -delete
S
cat > /opt/lab/i03/report.sh <<'S'
#!/usr/bin/env bash
echo "$(date '+%F %T') daily report: $(uptime)" >> "$HOME/i03-report.log"
S
cat > /opt/lab/i03/backup.sh <<'S'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /var/backups/i03
tar -czf "/var/backups/i03/etc-$(date +%Y%m%d-%H%M%S).tar.gz" -C / etc/hostname etc/hosts
date '+%F %T' > /var/backups/i03/last-run
echo "backup done ($(ls /var/backups/i03/*.tar.gz | wc -l) archives)"
S
chmod 755 /opt/lab/i03/*.sh
