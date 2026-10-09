#!/usr/bin/env bash
# a07 setup: generate a fresh day of JSON logs
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd python3 jq
prepare_answers
rm -rf /opt/lab/a07; mkdir -p /opt/lab/a07
info "Generating ~150k log lines..."
python3 "$LAB_DIR/gen.py" "$RANDOM$RANDOM" /opt/lab/a07
chmod -R a+rX /opt/lab/a07
ls -lh /opt/lab/a07/app.jsonl
