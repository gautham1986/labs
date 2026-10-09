#!/usr/bin/env bash
# i04 setup: three 512 MB loop "disks"
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd losetup mkfs.ext4 blkid
prepare_answers
bash "$LAB_DIR/cleanup.sh" >/dev/null 2>&1

[[ -e /dev/loop-control ]] || die "no loop device support here - use a VM (see README.md)"
mkdir -p /var/lib/lab/i04 /opt/lab/i04
: > /opt/lab/i04/DISKS
for i in 1 2 3; do
  img=/var/lib/lab/i04/disk$i.img
  truncate -s 512M "$img"
  dev=$(losetup -f --show "$img") || die "could not attach a loop device (all in use? try: losetup -D)"
  echo "DISK$i=$dev" >> /opt/lab/i04/DISKS
done
chmod 644 /opt/lab/i04/DISKS
cat /opt/lab/i04/DISKS

if ! has_dm; then
  warn "device-mapper is not available on this kernel: Part B (LVM) can't be done here."
  warn "Do Part A now, and Part B in a VM (env/Vagrantfile or multipass)."
fi
