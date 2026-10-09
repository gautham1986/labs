#!/usr/bin/env bash
# b07 setup: generate a fresh access log and users CSV
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd python3
prepare_answers
L=/opt/lab/b07
rm -rf "$L"; mkdir -p "$L"
python3 "$LAB_DIR/gen.py" "$RANDOM$RANDOM" "$L"
chmod -R a+rX "$L"
info "$(wc -l < "$L/access.log") log lines in $L/access.log"
