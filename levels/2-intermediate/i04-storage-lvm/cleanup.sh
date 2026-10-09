#!/usr/bin/env bash
# i04 cleanup: unmount, remove LVM, detach loops, remove fstab lines
source "$LAB_ROOT/lib/common.sh"
umount /srv/appdata 2>/dev/null
umount /mnt/logs 2>/dev/null
if command -v lvremove >/dev/null && has_dm; then
  lvremove -fy vgdata >/dev/null 2>&1
  vgremove -fy vgdata >/dev/null 2>&1
fi
if [[ -f /opt/lab/i04/DISKS ]]; then
  # shellcheck disable=SC1091
  source /opt/lab/i04/DISKS
  for d in "${DISK2:-}" "${DISK3:-}"; do [[ -n "$d" ]] && pvremove -fy "$d" >/dev/null 2>&1; done
fi
for img in /var/lib/lab/i04/disk*.img; do
  [[ -f "$img" ]] || continue
  losetup -j "$img" | cut -d: -f1 | while read -r dev; do losetup -d "$dev"; done
done
sed -i -E '\#[[:space:]](/mnt/logs|/srv/appdata)[[:space:]]#d' /etc/fstab
rm -rf /var/lib/lab/i04 /opt/lab/i04
exit 0
