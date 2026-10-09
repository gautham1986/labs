#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit lab-a04-api.service
rm -rf /opt/lab/a04 /etc/security/limits.d/batch.conf
if [[ -f /etc/sysctl.d/90-lab.conf ]]; then
  rm -f /etc/sysctl.d/90-lab.conf
  sysctl --system >/dev/null 2>&1
fi
userdel -r batch >/dev/null 2>&1
exit 0
