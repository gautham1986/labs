#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit flaky-health.timer flaky-health.service flaky-api.service
rm -rf /opt/lab/e07 /run/flaky /run/flaky-health.failures /usr/local/bin/flaky-healthcheck
exit 0
