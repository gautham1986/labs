#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
[[ -f /opt/lab/i04/DISKS ]] || die "run lab start i04 first"
# shellcheck disable=SC1091
source /opt/lab/i04/DISKS

fs_is()    { [[ "$(blkid -s TYPE -o value "$1")" == "$2" ]]; }
label_is() { [[ "$(blkid -s LABEL -o value "$1")" == "$2" ]]; }
mounted_from() {  # same major:minor device numbers
  local src; src=$(findmnt -n -o SOURCE "$2") || return 1
  [[ "$(stat -Lc %t:%T "$src")" == "$(stat -Lc %t:%T "$1")" ]]
}
fstab_entry() {  # fstab_entry <dev> <mountpoint> -> line references the device stably + nofail
  local uuid; uuid=$(blkid -s UUID -o value "$1")
  awk -v mp="$2" -v u="UUID=$uuid" -v lbl="$3" '
    $1 !~ /^#/ && $2 == mp && ($1 == u || $1 == "/dev/mapper/vgdata-lvapp" || $1 == "/dev/vgdata/lvapp" || $1 == "LABEL=" lbl) && $4 ~ /(^|,)nofail(,|$)/ { ok = 1 }
    END { exit !ok }' /etc/fstab
}
writable() { touch "$1/.lab-check" && rm -f "$1/.lab-check"; }
fstab_valid() { mount -fa; }
vg_has_both() { [[ "$(pvs --noheadings -o vg_name "$DISK2" "$DISK3" 2>/dev/null | tr -d ' ' | sort -u)" == vgdata ]]; }
lv_size_mb_at_least() { local s; s=$(lvs --noheadings --units m --nosuffix -o lv_size vgdata/lvapp 2>/dev/null | tr -d ' '); [[ -n "$s" ]] && awk -v s="$s" -v m="$1" 'BEGIN { exit !(s >= m) }'; }
fs_size_mb_at_least() { local s; s=$(df -Pm /srv/appdata | awk 'NR == 2 { print $2 }'); (( s >= $1 )); }

section "Part A - filesystem on DISK1 ($DISK1)"
check "DISK1 has an ext4 filesystem" fs_is "$DISK1" ext4
check "DISK1 is labelled 'logs'" label_is "$DISK1" logs
check "DISK1 is mounted at /mnt/logs" mounted_from "$DISK1" /mnt/logs
check "/mnt/logs is writable" writable /mnt/logs
check "/etc/fstab mounts it by UUID with nofail" fstab_entry "$DISK1" /mnt/logs logs
check "/etc/fstab parses cleanly (mount -fa)" fstab_valid

section "Part B - LVM on DISK2 + DISK3"
if ! has_dm; then
  warn "device-mapper not available here - Part B skipped (do it in a VM)"
else
  check "volume group vgdata uses both DISK2 and DISK3" vg_has_both
  check "logical volume vgdata/lvapp exists" lvs vgdata/lvapp
  check "lvapp has an ext4 filesystem labelled appdata" label_is /dev/vgdata/lvapp appdata
  check "lvapp is mounted at /srv/appdata" mounted_from /dev/vgdata/lvapp /srv/appdata
  check "/etc/fstab mounts /srv/appdata with nofail" fstab_entry /dev/vgdata/lvapp /srv/appdata appdata
  check "lvapp was grown to >= 800M" lv_size_mb_at_least 795
  check "the filesystem was grown too (df shows >= 700M)" fs_size_mb_at_least 700
fi

finish
