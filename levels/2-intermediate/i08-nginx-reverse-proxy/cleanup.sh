#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit i08-backend.service
rm -f /etc/nginx/sites-enabled/i08.conf /etc/nginx/sites-available/i08.conf /var/log/nginx/i08.*
rm -rf /opt/lab/i08
if [[ -e /etc/nginx/sites-available/default && ! -e /etc/nginx/sites-enabled/default ]]; then
  ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
fi
has_systemd && systemctl disable --now nginx >/dev/null 2>&1
exit 0
