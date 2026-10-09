#!/usr/bin/env bash
# i01 setup: drop the app in place; the service is yours to build
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
prepare_answers
bash "$LAB_DIR/cleanup.sh"
install_app /opt/lab/i01/inventory.py
info "App installed at /opt/lab/i01/inventory.py (try: python3 /opt/lab/i01/inventory.py --help)"
