# Roadmap: Linux for DevOps & SRE, beginner to expert

How to use this: work through the levels in order, interleaving the scripting track as shown.
Each level ends with a self-check. If you can't do everything on it without notes, repeat the
labs you struggled with (`lab reset <id>` gives you a fresh, re-randomized scenario).

Suggested pace: **~12 weeks at 6-8 hours/week.** Faster is fine; skipping the "Explore"
sections is not - that's where most of the depth is.

Keep a learning log: `cp templates/learning-log.md workspace/notes/`. Writing down *why* something
worked is what turns lab time into interview answers.

---

## Level 1 · Beginner - "I can live in a Linux shell" (weeks 1-3)

**Goal:** move around, read and change files, manage users and permissions, understand processes,
and chain commands into pipelines without reaching for a GUI.

| Lab | Topic | Key commands |
|---|---|---|
| b01 | Navigating the filesystem | `cd` `ls -la` `find` `du` `mkdir -p` · FHS |
| b02 | Files, links & archives | `ln -s` `ln` `tar -czf/-xJf -C` `cp -a` `file` |
| b03 | Users, groups & sudo | `useradd` `usermod -aG` `chage` `id` · setgid dirs |
| b04 | Permissions & ACLs | `chmod` (octal/symbolic) `chown` `umask` `setfacl` · sticky/setgid |
| b05 | Package management | `apt` `dpkg -S/-L` `apt-mark hold` |
| b06 | Processes & signals | `ps` `top` `kill -TERM/-HUP` `nice/renice` · zombies |
| b07 | Text processing | `grep` `cut` `sort \| uniq -c \| sort -rn` `awk` |
| b08 | Shell environment | `.bashrc` vs `.profile` `PATH` `alias` functions `2>` `2>&1` |

**Scripting:** s01 (arguments & exit codes), s02 (arithmetic & case), s03 (file tests).

**You're ready for Level 2 when you can, without notes:**
- [ ] explain what `rwxr-x---`, `2770` and `1777` mean and when you'd use each
- [ ] find the 5 biggest files under a directory and the 5 most common IPs in a log
- [ ] explain the difference between a hard link and a symlink, and what `rm` does to each
- [ ] tell `SIGTERM` from `SIGKILL` from `SIGHUP`, and why zombies can't be killed
- [ ] explain why `cmd > out 2>&1` and `cmd 2>&1 > out` differ
- [ ] add a user to a group without removing their other groups

---

## Level 2 · Intermediate - "I can run services on a server" (weeks 4-6)

**Goal:** operate a single server like a sysadmin: services, logs, schedules, storage, network,
remote access, firewall and a web front end.

| Lab | Topic | Key commands |
|---|---|---|
| i01 | systemd services | unit files, `systemctl enable --now`, `Restart=`, `journalctl -u` |
| i02 | Logs | `journalctl -p/-t/-u`, journald drop-ins, `logger`, logrotate |
| i03 | Scheduling | cron (`/etc/cron.d` vs `crontab -e`), systemd timers, `Persistent=` |
| i04 | Storage | `mkfs`, `blkid`, fstab with UUID + `nofail`, LVM (`pvcreate`...`lvextend -r`) |
| i05 | Networking basics | `ip addr/route`, `ss -tulpn`, `/etc/hosts`, `resolv.conf`, `getent` |
| i06 | SSH | ed25519 keys, `authorized_keys` perms, `~/.ssh/config`, `sshd -t/-T`, drop-ins |
| i07 | Firewall | nftables default-deny, conntrack, rate limits, persistence |
| i08 | nginx | reverse proxy, `X-Forwarded-*`, static files, gzip, `nginx -t` |

**Scripting:** s04 (safe loops), s05 (functions, sourceable scripts), s06 (associative arrays).

**You're ready for Level 3 when you can:**
- [ ] write a unit file from memory that runs as its own user and restarts on failure
- [ ] find yesterday's errors for one service in the journal in one command
- [ ] add a disk, put a filesystem on it, and mount it persistently - and explain `nofail`
- [ ] explain what happens, layer by layer, when you `curl http://example.com`
- [ ] lock down SSH to keys only without locking yourself out
- [ ] explain what a reverse proxy does and why the backend needs `X-Forwarded-For`

---

## Level 3 · Advanced - "I can fix it when it breaks" (weeks 7-9)

**Goal:** structured troubleshooting under pressure. Every lab here is a broken system with
stacked faults. Practice the method in `cheatsheets/troubleshooting.md`: observe, hypothesize,
test one thing, repeat.

| Lab | Scenario | Skills |
|---|---|---|
| a01 | Disk full - twice | `df` vs `du`, deleted-but-open files (`lsof +L1`), inode exhaustion |
| a02 | Service won't start | systemd exit codes (`203/EXEC`, `217/USER`), permissions, port conflicts |
| a03 | Process keeps coming back | process trees, disguised processes, persistence (cron), eradication |
| a04 | Limits & kernel tuning | `LimitNOFILE`, `limits.d`, PAM, `sysctl.d` |
| a05 | Can't reach the API | resolution -> routing -> port -> filter; timeout vs refused |
| a06 | Black-box debugging | `strace -e openat,connect`, reading syscalls |
| a07 | Log analysis at scale | `jq`, awk aggregation, percentiles, malformed input |
| a08 | Backup & restore | rsync `--link-dest` snapshots, manifests, retention, verified restore |

**Scripting:** s07 (log pipelines), s08 (getopts & dry runs), s09 (traps & atomic writes).

**You're ready for Level 4 when you can:**
- [ ] explain why `df` and `du` disagree, and fix it without a reboot
- [ ] read a `systemctl status` line and say which stage failed
- [ ] debug "it can't connect" by distinguishing DNS, routing, refused and filtered
- [ ] use `strace` to find which file or port a program is trying to use
- [ ] compute a p95 from raw logs and explain why averages lie
- [ ] restore a backup and *prove* it's identical

---

## Level 4 · Expert - "I can run production as an SRE" (weeks 10-12)

**Goal:** think in systems: reliability targets, observability, safe change, automation,
security and incident response.

| Lab | Topic | Skills |
|---|---|---|
| e01 | Incident: 502 | mitigation first, multi-fault diagnosis, blameless postmortem |
| e02 | Observability | Prometheus exposition format, textfile collector, atomic writes, alert rules |
| e03 | SLOs & error budgets | SLI math, budget remaining, multi-window burn-rate alerting |
| e04 | Namespaces & cgroups | what containers really are: cgroup v2 limits, OOM, `unshare`/`nsenter` |
| e05 | Security audit | UID 0 backdoors, SUID, sudoers, cron, sshd, rogue listeners |
| e06 | Zero-downtime deploys | blue/green, health gating, atomic switch, failing safe |
| e07 | Self-healing | `Restart=` + start limits, health-check timers, runbooks |
| e08 | Triage toolkit | one-command diagnostic bundles with automatic findings |

**Scripting:** s10 (retry & backoff), s11 (jq), s12 (parallel health checker - capstone).

**Then:** the [projects](projects/README.md) - multi-node work on `lab`, `node1`, `node2`.

**You're "expert-ready" when you can:**
- [ ] run an incident: communicate, mitigate, find root causes, write the postmortem
- [ ] define an SLO for a service, compute its error budget and write burn-rate alerts
- [ ] explain how a container is built from namespaces + cgroups, and debug one with `nsenter`
- [ ] audit a Linux host for persistence and privilege-escalation paths
- [ ] design a deploy that can't take the site down, and prove it under load
- [ ] build tooling other engineers use at 3am

---

## Beyond this lab

This repo is about **Linux fundamentals** - the layer every other tool sits on. Natural next steps
(each deserves its own lab):

| Area | Learn | Why it builds on this |
|---|---|---|
| Containers | Docker/Podman, image builds, compose | e04 showed you the kernel side |
| Orchestration | Kubernetes (kind/k3s locally) | probes = e07, rolling updates = e06, limits = a04/e04 |
| Config management | Ansible | P1/P2 in bash first, then see why Ansible exists |
| Infrastructure as code | Terraform/OpenTofu | |
| CI/CD | GitHub Actions/GitLab CI | P4: deploy pipeline |
| Observability | Prometheus, Grafana, Loki, OpenTelemetry | e02, e03 |
| Cloud | one of AWS/GCP/Azure: networking + IAM first | i05/a05 networking, e05 security |
| Performance | Brendan Gregg's USE method, `perf`, eBPF/bcc | a06, e08 |

## Reading list

- *The Linux Command Line* - William Shotts (free online) - Level 1-2
- *How Linux Works* - Brian Ward - Level 2-3
- *UNIX and Linux System Administration Handbook* - Nemeth et al. - reference
- *Site Reliability Engineering* + *The Site Reliability Workbook* - Google (free online) - Level 4
- *Systems Performance* - Brendan Gregg - Level 3-4
- [Linux Performance Analysis in 60,000 ms](https://netflixtechblog.com/linux-performance-analysis-in-60-000-milliseconds-accc10403c55) - Netflix
- [BashPitfalls](https://mywiki.wooledge.org/BashPitfalls) - read it once a year
