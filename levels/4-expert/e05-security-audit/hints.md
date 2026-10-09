Accounts first: `awk -F: '$3 == 0 {print $1}' /etc/passwd` - only `root` should appear.
`sudo awk -F: '$2 == "" {print $1}' /etc/shadow` finds accounts with no password at all.
Disable or delete them (`userdel`, `passwd -l`, `usermod -s /usr/sbin/nologin`).
---
Privilege: `sudo grep -r . /etc/sudoers.d/` and `sudo find / -xdev -perm /6000 -type f 2>/dev/null | grep -v -e ^/usr/bin -e ^/usr/lib -e ^/usr/sbin`
Hidden files (`.name`) in `/usr/local/bin` are a red flag.
---
`ls -l /etc/shadow` should be `640 root:shadow` (or `600`). Then look at what root runs from cron:
`cat /etc/cron.d/*` - and check the permissions of every script referenced there.
A world-writable script run by root = anyone can become root.
---
SSH: `sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication'`. Drop-ins in
`/etc/ssh/sshd_config.d/` are read in order, and the *first* value wins. Also audit
`/root/.ssh/authorized_keys` - do you recognise every key?
---
Network: `sudo ss -tulpn`. Anything unexpected listening? Find its unit
(`systemctl status <PID>` shows which unit a PID belongs to), stop/disable it and remove the binary.
