#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit inventory.service
rm -f /etc/default/inventory
userdel inventory >/dev/null 2>&1
groupdel inventory >/dev/null 2>&1
exit 0
