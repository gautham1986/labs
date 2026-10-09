# b03 · Users, groups & sudo

**Level:** Beginner · **Time:** ~25 min · **Needs:** any Linux

## Scenario

A new DevOps team is joining. You need accounts for them, a shared workspace where everyone
in the team can edit each other's files, and a service account for an app.

## Tasks

1. Create groups `devops` and `auditors`.
2. Create users `alice` and `bob` with home directories and `/bin/bash` as shell.
   Both must be members of `devops` (as a supplementary group).
3. Give `alice` admin rights by adding her to the `sudo` group.
4. `bob` is a contractor: make his account **expire on 2030-12-31**.
5. Create user `carol` in group `auditors` with shell `/bin/bash`.
6. Create a **system** account `appsvc` (UID below 1000) that **cannot log in**
   (shell `/usr/sbin/nologin`) and has home `/var/lib/appsvc`.
7. Create a shared directory `/srv/devops`:
   - owned by `root`, group `devops`
   - members of `devops` can read/write/enter; others have **no** access
   - new files created inside automatically belong to group `devops` (setgid bit)

## Commands to learn

`useradd` (`-m -s -G -r -d`) `usermod -aG` `groupadd` `passwd` `chage -l / -E` `id` `groups`
`getent passwd|group|shadow` `su - user` `sudo -l -U user` `chmod 2770` `chgrp`
Files: `/etc/passwd` `/etc/group` `/etc/shadow` `/etc/sudoers.d/`

## Done when

`lab check b03` passes. Run `lab clean b03` afterwards to delete these users.

## Explore (not graded)

- `sudo -u alice touch /srv/devops/a.txt` then `ls -l /srv/devops`. Which group owns it? Remove
  the setgid bit and try again.
- What's the difference between `usermod -G devops bob` and `usermod -aG devops bob`?
  (This mistake has locked many admins out of `sudo`.)
- Read `/etc/login.defs`: where do the UID ranges for normal vs system users come from?
- Instead of the `sudo` group, write a drop-in `/etc/sudoers.d/alice` that lets alice run only
  `systemctl restart nginx`. Always edit with `visudo -f`!
