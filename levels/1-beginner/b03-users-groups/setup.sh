#!/usr/bin/env bash
# b03 setup: start from a clean slate (remove anything left from a previous attempt)
source "$LAB_ROOT/lib/common.sh"
need_root
bash "$LAB_DIR/cleanup.sh"
prepare_answers
info "No scenario to build - this lab starts from scratch."
