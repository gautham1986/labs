#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit report-svc.service minicache.service
rm -rf /opt/lab/a06 /var/lib/report-svc
exit 0
