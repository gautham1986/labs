#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit orders-worker.service
rm -rf /opt/lab/i02 /var/log/orders /etc/logrotate.d/orders
exit 0
