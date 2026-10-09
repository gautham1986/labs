# Troubleshooting method

## The loop
1. **Define the symptom precisely.** What fails, for whom, since when, how often? "Site down" ->
   "`GET /checkout` returns 502 for all users since 03:12".
2. **Mitigate first** if users are hurting (roll back, fail over, scale, restart) - *then* debug.
3. **Follow the request path** and test each hop: client -> DNS -> network -> LB/proxy -> app ->
   dependencies (DB, cache, disk).
4. **One hypothesis, one test.** Change one thing, re-test, write it down (timestamps!).
5. **What changed?** Deploys, config, certs, traffic, disk growth, kernel updates. `journalctl
   --since`, `rpm -qa --last` / `/var/log/apt/history.log`, git log of config repos.
6. **Fix the root cause, then prevent recurrence** (postmortem action items).

## The first 60 seconds on a box (after Netflix's checklist)
```bash
uptime                      # load averages: trend up or down?
dmesg -T | tail             # OOM kills, disk/network errors
vmstat 1 5                  # r (run queue), si/so (swapping), wa (I/O wait)
mpstat -P ALL 1 3           # one CPU pegged?
pidstat 1 3                 # which processes
iostat -xz 1 3              # %util, await per disk
free -m                     # available memory (not "free")
sar -n DEV 1 3              # network throughput
sar -n TCP,ETCP 1 3         # retransmits
top                         # sanity check
df -h; df -i                # space AND inodes
systemctl --failed          # anything down?
journalctl -p err -b | tail -50
```

## USE method (for every resource: CPU, memory, disk, network)
- **U**tilization - how busy? (`mpstat`, `free`, `iostat %util`, `sar -n DEV`)
- **S**aturation - how much queued work? (load/run queue, swapping, `await`, drops)
- **E**rrors - any? (`dmesg`, `ip -s link`, `netstat -s`, SMART)

## RED method (for every service)
- **R**ate - requests per second
- **E**rrors - failed requests per second
- **D**uration - latency distribution (p50/p95/p99, not averages)

## Network: timeout vs refused
| Symptom | Usually means |
|---|---|
| `Connection refused` (instant) | host reachable, nothing listening on that port (or REJECT rule) |
| timeout | wrong IP/route, host down, or a firewall silently DROPping |
| `No route to host` | routing/ARP problem, or ICMP-unreachable from a firewall |
| `Name or service not known` | DNS / `/etc/hosts` / nsswitch |
| TLS errors | clock skew, wrong SNI/hostname, expired or untrusted cert |
| 502 from a proxy | upstream refused/reset/garbage |
| 504 from a proxy | upstream too slow (timeouts) |

## systemd exit codes worth memorizing
| `status=` | Meaning |
|---|---|
| `203/EXEC` | ExecStart binary missing / not executable / bad shebang |
| `217/USER` | `User=` doesn't exist |
| `200/CHDIR` | `WorkingDirectory=` missing |
| `226/NAMESPACE` | sandboxing option failed (e.g. `ProtectSystem` path missing) |
| `1/FAILURE` | the app itself exited 1 - read its logs |
| `9/KILL` / `15/TERM` | killed by a signal (OOM killer => check `dmesg`) |

## Disk
- `df` full but `du` small -> deleted files still open: `lsof +L1`
- "No space left" with free space -> inodes: `df -i`
- slow -> `iostat -xz 1` (`await`, `%util`), `iotop`, processes in `D` state

## Memory
- "free" is low is normal; look at `available`
- OOM kills: `dmesg -T | grep -i 'killed process'`, `journalctl -k`
- per-process: `ps -eo pid,rss,comm --sort=-rss | head`, `smem`, `/proc/PID/status`
