Read the disk names: `cat /opt/lab/i04/DISKS`, then `source` it or copy the names.
`sudo mkfs.ext4 -L logs $DISK1` and `sudo blkid $DISK1` shows the UUID.
---
fstab line format: `<what> <where> <type> <options> <dump> <pass>`
`UUID=xxxx-...  /mnt/logs  ext4  defaults,nofail  0  2`
Create the mount point first (`mkdir -p`), then `sudo mount -a` mounts everything in fstab -
a great test that your line is correct.
---
LVM is three layers: PV (disk) -> VG (pool) -> LV (volume).
`sudo pvcreate $DISK2 $DISK3`, `sudo vgcreate vgdata $DISK2 $DISK3`,
`sudo lvcreate -L 600M -n lvapp vgdata`. The LV is `/dev/vgdata/lvapp`.
---
Growing: `sudo lvextend -r -L +200M vgdata/lvapp`. `-r` also resizes the filesystem
(it calls `resize2fs` for you). Check with `df -h /srv/appdata` and `lvs`.
