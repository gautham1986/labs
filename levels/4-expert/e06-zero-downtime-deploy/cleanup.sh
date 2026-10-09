#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
has_systemd && systemctl stop app@blue app@green >/dev/null 2>&1
rm -f /etc/systemd/system/app@.service
has_systemd && systemctl daemon-reload
rm -rf /opt/lab/e06 /etc/e06 /etc/nginx/e06-upstream.conf
rm -f /etc/nginx/sites-enabled/e06.conf /etc/nginx/sites-available/e06.conf
if has_systemd && systemctl is-active --quiet nginx; then
  others=$(find /etc/nginx/sites-enabled -mindepth 1 ! -name default 2>/dev/null)
  if [[ -z "$others" ]]; then
    systemctl disable --now nginx >/dev/null 2>&1
  else
    systemctl reload nginx >/dev/null 2>&1
  fi
fi
exit 0
