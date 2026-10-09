#!/usr/bin/env bash
# b05 setup: make sure the packages are NOT installed so you get to install them
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd apt-get dpkg
prepare_answers
apt-mark unhold ncdu >/dev/null 2>&1
if dpkg -s tree >/dev/null 2>&1 || dpkg -s ncdu >/dev/null 2>&1; then
  info "Removing tree/ncdu so you can install them yourself"
  DEBIAN_FRONTEND=noninteractive apt-get remove -y -q tree ncdu >/dev/null 2>&1
fi
exit 0
