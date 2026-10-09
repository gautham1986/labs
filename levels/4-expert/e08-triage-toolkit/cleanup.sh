#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
umount /srv/e08 2>/dev/null; rmdir /srv/e08 2>/dev/null
has_systemd && systemctl reset-failed lab-e08-broken.service >/dev/null 2>&1
rm -f /etc/systemd/system/lab-e08-broken.service
has_systemd && systemctl daemon-reload
exit 0
