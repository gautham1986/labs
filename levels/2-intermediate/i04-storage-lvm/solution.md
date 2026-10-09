# i04 · Solution

```bash
source /opt/lab/i04/DISKS          # DISK1 DISK2 DISK3

# Part A
sudo mkfs.ext4 -q -L logs "$DISK1"
UUID1=$(sudo blkid -s UUID -o value "$DISK1")
sudo mkdir -p /mnt/logs
echo "UUID=$UUID1  /mnt/logs  ext4  defaults,nofail  0  2" | sudo tee -a /etc/fstab
sudo mount -a
findmnt /mnt/logs

# Part B
sudo pvcreate "$DISK2" "$DISK3"
sudo vgcreate vgdata "$DISK2" "$DISK3"
sudo lvcreate -y -L 600M -n lvapp vgdata
sudo mkfs.ext4 -q -L appdata /dev/vgdata/lvapp
UUID2=$(sudo blkid -s UUID -o value /dev/vgdata/lvapp)
sudo mkdir -p /srv/appdata
echo "UUID=$UUID2  /srv/appdata  ext4  defaults,nofail  0  2" | sudo tee -a /etc/fstab
sudo mount -a

# grow LV and filesystem online
sudo lvextend -r -L +200M vgdata/lvapp
sudo lvs; df -h /srv/appdata
sudo findmnt --verify || true
```

## Why

- UUIDs and labels are stable; `/dev/sdX` (and loop) names depend on discovery order.
- `nofail` prevents a missing data disk from blocking boot. The last field (`2`) means "fsck after
  the root filesystem".
- LVM decouples filesystems from physical disks: span disks, grow online, snapshot. Most cloud
  images and installers use it for exactly that reason.
- `lvextend -r` grows the block device and the filesystem in one step; forgetting the second
  half ("I extended the LV but df shows the same size") is a classic.
