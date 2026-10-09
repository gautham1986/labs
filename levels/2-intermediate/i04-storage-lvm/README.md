# i04 · Disks, filesystems, fstab & LVM

**Level:** Intermediate · **Time:** ~45 min · **Needs:** root, loop devices; LVM part needs device-mapper (any VM, Docker Desktop, most Linux hosts)

## Scenario

Three new "disks" were attached to this server (they're loop devices backed by files, so
nothing real gets hurt). The setup prints their names and saves them in `/opt/lab/i04/DISKS`:

```
DISK1=/dev/loopX   # 512 MB
DISK2=/dev/loopY   # 512 MB
DISK3=/dev/loopZ   # 512 MB
```

## Tasks

**Part A - a plain filesystem**

1. Create an **ext4** filesystem on `DISK1` with the label `logs`.
2. Mount it at `/mnt/logs`, and make the mount **permanent** in `/etc/fstab` using the
   filesystem's **UUID** (not `/dev/loopX`, device names can change) and the `nofail` option
   (so the box still boots if the disk is missing).

**Part B - LVM**

3. Turn `DISK2` and `DISK3` into LVM physical volumes and create a volume group `vgdata` from both.
4. Create a logical volume `lvapp` of **600M** in `vgdata` (bigger than either disk alone!).
5. Format it **ext4** with label `appdata`, mount it at `/srv/appdata`, and add it to `/etc/fstab`
   (by UUID or `/dev/mapper/vgdata-lvapp`, with `nofail`).
6. The app needs more room: **grow** `lvapp` by **200M** *and* the filesystem on it, while mounted.

Run `sudo mount -a` and `findmnt --verify` after editing fstab - a broken fstab can make a real
server drop into emergency mode on the next boot.

## Commands to learn

`lsblk -f` `blkid` `mkfs.ext4 -L` `mount` / `umount` `findmnt` `df -hT` `df -i` `/etc/fstab`
`mount -a` `findmnt --verify` `pvcreate` `pvs` `vgcreate` `vgs` `lvcreate -L -n` `lvs`
`lvextend -r` (or `lvextend` + `resize2fs`) `tune2fs -l` `e2label`

## Done when

`lab check i04` passes. Run `lab clean i04` afterwards to detach the loop devices.
(After restarting the container/VM, loop devices are gone - `lab reset i04`.)

## Explore (not graded)

- In a VM with a spare disk, partition it with `parted` (GPT, one partition), then `lsblk`.
- `xfs` can grow but never shrink; `ext4` can shrink offline. Why does that matter for LVM?
- Take an LVM snapshot of `lvapp`, delete a file, mount the snapshot read-only and recover it.
- `tune2fs -l /dev/vgdata/lvapp | grep -i 'reserved block'` - why does ext4 reserve 5% for root?
