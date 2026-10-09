#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
rm -f /etc/ssh/sshd_config.d/*hardening*.conf
has_systemd && systemctl reload ssh >/dev/null 2>&1
userdel -r deploy >/dev/null 2>&1
rm -rf /opt/lab/i06
echo "Note: your ~/.ssh keys and config were left in place."
exit 0
