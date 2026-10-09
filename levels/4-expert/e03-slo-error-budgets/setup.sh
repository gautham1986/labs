#!/usr/bin/env bash
# e03 setup: 30 days of per-minute SLI data
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd python3
prepare_answers
rm -rf /opt/lab/e03; mkdir -p /opt/lab/e03
python3 "$LAB_DIR/gen.py" "$RANDOM$RANDOM" /opt/lab/e03
chmod -R a+rX /opt/lab/e03
info "$(($(wc -l < /opt/lab/e03/requests-30d.csv) - 1)) minutes of data in /opt/lab/e03/requests-30d.csv"
