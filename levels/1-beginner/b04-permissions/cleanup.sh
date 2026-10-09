#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
rm -rf /srv/b04
userdel -r webdev >/dev/null 2>&1
groupdel webops >/dev/null 2>&1
exit 0
