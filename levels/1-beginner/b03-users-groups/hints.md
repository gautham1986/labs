Groups first: `groupadd devops`. Then `useradd -m -s /bin/bash -G devops alice`.
`-m` creates the home directory, `-G` sets supplementary groups.
---
To add an *existing* user to another group, use `usermod -aG GROUP USER`. Without `-a`,
`-G` *replaces* all supplementary groups.
---
Account expiry: `chage -E 2030-12-31 bob` and verify with `chage -l bob`.
---
System accounts: `useradd -r -s /usr/sbin/nologin -d /var/lib/appsvc -m appsvc`.
`-r` picks a UID from the system range (below 1000 on Debian/Ubuntu).
---
The shared dir: create it, `chown root:devops`, then `chmod 2770`. The leading `2` is the
setgid bit: files created inside inherit the directory's group. `ls -ld` shows it as `s`
in the group execute position: `drwxrws---`.
