#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit shop.service
umount /var/lib/shop/cache 2>/dev/null
rm -rf /var/lib/shop /opt/lab/e01
rm -f /etc/nginx/sites-enabled/shop.conf /etc/nginx/sites-available/shop.conf
if has_systemd && systemctl is-active --quiet nginx; then
  others=$(find /etc/nginx/sites-enabled -mindepth 1 ! -name default 2>/dev/null)
  if [[ -z "$others" ]]; then
    systemctl disable --now nginx >/dev/null 2>&1
  else
    systemctl reload nginx >/dev/null 2>&1
  fi
fi
userdel shop >/dev/null 2>&1; groupdel shop >/dev/null 2>&1
exit 0
