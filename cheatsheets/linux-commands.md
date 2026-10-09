# Linux command cheatsheet (by task)

## Files & navigation
| Task | Command |
|---|---|
| where am I / go back | `pwd` · `cd -` |
| list incl. hidden, human sizes, by size | `ls -lahS` |
| find by name / type / size / age | `find /var -type f -name '*.log' -size +100M -mtime +7` |
| act on found files (batched) | `find . -name '*.tmp' -exec rm {} +` |
| biggest dirs on this filesystem | `du -xh --max-depth=1 / \| sort -h \| tail` |
| file type / metadata | `file x` · `stat x` · `stat -c '%a %U:%G %s %n' x` |
| links | `ln -s target link` · `ln target hardlink` · `readlink -f link` |
| archives | `tar -czf a.tgz -C dir .` · `tar -tzf a.tgz` · `tar -xf a.tgz -C dest` |
| copy preserving everything | `cp -a src dst` · `rsync -aHAX --delete src/ dst/` |

## Text
| Task | Command |
|---|---|
| count / first / last / follow | `wc -l` · `head -n 20` · `tail -n 50` · `tail -F` |
| search recursively, with context | `grep -rn --include='*.conf' -C2 pattern /etc` |
| fields | `cut -d: -f1 /etc/passwd` · `awk -F, '{print $3}'` |
| frequency count | `... \| sort \| uniq -c \| sort -rn \| head` |
| replace in place (backup) | `sed -i.bak 's/old/new/g' file` |
| JSON | `jq -r '.items[] \| select(.ok) \| .name'` |
| compare | `diff -u a b` · `comm -12 <(sort a) <(sort b)` |

## Users & permissions
| Task | Command |
|---|---|
| who am I / groups | `id` · `groups` · `whoami` |
| add user to group (keep others!) | `usermod -aG group user` |
| system user | `useradd -r -s /usr/sbin/nologin -d /var/lib/app app` |
| password aging | `chage -l user` · `chage -E 2030-12-31 user` |
| perms / owner | `chmod 640 f` · `chmod -R u=rwX,go=rX d` · `chown user:group f` |
| ACLs | `setfacl -m u:alice:r f` · `getfacl f` |
| sudo rules | `visudo -f /etc/sudoers.d/x` · `sudo -l -U user` |

## Processes & resources
| Task | Command |
|---|---|
| top CPU / memory | `ps -eo pid,ppid,user,pcpu,pmem,stat,etime,comm --sort=-pcpu \| head` |
| tree | `ps -ef --forest` · `pstree -ap` |
| signal | `kill -TERM pid` · `pkill -HUP -x nginx` · `kill -l` |
| priority | `nice -n 10 cmd` · `renice -n 15 -p pid` |
| open files / who uses a file | `lsof -p pid` · `lsof /path` · `lsof +L1` · `fuser -v /mnt` |
| limits | `ulimit -a` · `cat /proc/PID/limits` · `prlimit --pid PID` |
| quick health | `uptime` · `free -m` · `vmstat 1 5` · `iostat -xz 1` · `mpstat -P ALL 1` |
| syscalls | `strace -f -e trace=openat,connect -p PID` |

## systemd & logs
| Task | Command |
|---|---|
| status / logs | `systemctl status x` · `journalctl -u x -e` · `journalctl -u x -f` |
| errors this boot | `journalctl -p err -b` |
| by tag / since | `journalctl -t tag --since '1 hour ago'` |
| enable + start | `systemctl enable --now x` |
| override a unit | `systemctl edit x` (drop-in) · `systemctl cat x` · `daemon-reload` |
| what failed | `systemctl --failed` · `systemctl reset-failed x` |
| timers | `systemctl list-timers` · `systemd-analyze calendar 'Mon..Fri 02:30'` |
| boot time | `systemd-analyze blame` |

## Storage
| Task | Command |
|---|---|
| block devices & filesystems | `lsblk -f` · `blkid` · `findmnt` |
| usage / inodes | `df -hT` · `df -i` |
| make & mount | `mkfs.ext4 -L data /dev/x` · `mount /dev/x /mnt` · `mount -a` |
| fstab line | `UUID=...  /data  ext4  defaults,nofail  0  2` |
| LVM | `pvs` `vgs` `lvs` · `lvcreate -L 10G -n lv vg` · `lvextend -r -L +5G vg/lv` |

## Networking
| Task | Command |
|---|---|
| addresses / routes | `ip -br a` · `ip r` · `ip route get 1.1.1.1` |
| listening sockets | `ss -tulpn` · `ss -tan state established` |
| name resolution | `getent hosts name` · `dig +short name` · `resolvectl status` |
| connectivity | `ping -c3` · `mtr -rwc 10 host` · `nc -zv host 443` · `curl -sv URL` |
| HTTP timing | `curl -o /dev/null -s -w '%{http_code} %{time_connect} %{time_total}\n' URL` |
| packets | `tcpdump -ni any port 53` |
| firewall | `nft list ruleset` · `iptables -L -n -v` · `ufw status` |

## Packages (Debian/Ubuntu vs RHEL/Fedora)
| Task | apt/dpkg | dnf/rpm |
|---|---|---|
| install | `apt install x` | `dnf install x` |
| which package owns a file | `dpkg -S /path` | `rpm -qf /path` |
| files in a package | `dpkg -L x` | `rpm -ql x` |
| pin a version | `apt-mark hold x` | `dnf versionlock add x` |
