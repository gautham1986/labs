# e05 · Security audit & hardening

**Level:** Expert · **Time:** ~75 min · **Needs:** systemd, sshd, cron

## Scenario

You inherited this box from a team that's gone. Security got an alert about it and suspects it was
tampered with. Audit it like an attacker would look at it - **at least 9 problems** are planted
(accounts, privileges, file permissions, scheduled jobs, SSH, network listeners) - and fix every one
without breaking legitimate access (your own sudo, `sshd`, `cron`).

## Tasks

1. Audit the system. Write your findings to `~/answers/e05-findings.md`: **one bullet per finding**
   (`- ...`), each with *what*, *why it's dangerous* and *what you did*.
2. Remediate every finding.
3. Don't lock yourself out: your user must keep `sudo`, `sshd` and `cron` must keep running, and
   `visudo -c` must pass.

## Where to look

| Area | Starting points |
|---|---|
| Accounts | `/etc/passwd` (UID 0?), `/etc/shadow` (empty passwords?), `getent group sudo` |
| Privileges | `/etc/sudoers`, `/etc/sudoers.d/`, SUID/SGID binaries in odd places |
| Files | permissions on `/etc/passwd`, `/etc/shadow`, scripts that root runs |
| Scheduled | `/etc/cron.d/`, `/etc/crontab`, `crontab -l -u root`, systemd timers |
| Remote access | `sshd -T`, `/etc/ssh/sshd_config.d/`, `~/.ssh/authorized_keys` of every user incl. root |
| Network | `ss -tulpn`, enabled services: `systemctl list-unit-files --state=enabled` |

## Commands to learn

`awk -F: '$3 == 0' /etc/passwd` `awk -F: '$2 == ""' /etc/shadow` `find / -xdev -perm -4000 -type f`
`find / -xdev -perm -0002 -type f` `stat -c '%a %U:%G %n'` `sudo -l -U USER` `visudo -c`
`sshd -T` `ssh-keygen -lf FILE` `ss -tulpn` `systemctl list-unit-files --state=enabled`
`lastlog` `last` `journalctl _COMM=sshd` `dpkg --verify` (find modified package files)

## Done when

`lab check e05` passes. `lab clean e05` removes anything left of the scenario.

## Explore (not graded)

- `dpkg --verify` lists package files that changed since install. What does it flag?
- Run `lynis audit system` (apt install lynis) and compare with your list.
- Write a script that checks all of this automatically and run it from a timer (a mini-IDS).
- In a real compromise: isolate, preserve evidence, rotate *all* credentials, rebuild from a known
  good image. Cleaning in place is never fully trustworthy.
