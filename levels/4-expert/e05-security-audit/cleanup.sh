#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
sed -i '/^toor:/d' /etc/passwd /etc/shadow 2>/dev/null
userdel -r svc-backup >/dev/null 2>&1
rm -f /etc/sudoers.d/99-svc /usr/local/bin/.sysutil /etc/cron.d/e05-maintenance /etc/ssh/sshd_config.d/00-legacy.conf
rm -rf /opt/lab/e05
if [[ -f "$LAB_VAR/e05/shadow.orig" ]]; then
  read -r m u g < "$LAB_VAR/e05/shadow.orig"; chown "$u:$g" /etc/shadow; chmod "$m" /etc/shadow
fi
if [[ -f "$LAB_VAR/e05/planted_key.pub" && -f /root/.ssh/authorized_keys ]]; then
  grep -vF "$(awk '{print $2}' "$LAB_VAR/e05/planted_key.pub")" /root/.ssh/authorized_keys > /root/.ssh/ak.tmp || true
  mv /root/.ssh/ak.tmp /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys
fi
remove_unit netsvcd.service
pkill -x netsvcd 2>/dev/null; rm -f /usr/local/sbin/netsvcd
has_systemd && systemctl reload ssh >/dev/null 2>&1
rm -rf "$LAB_VAR/e05"
exit 0
