# a04 · Resource limits & kernel tuning

**Level:** Advanced · **Time:** ~35 min · **Needs:** systemd

## Scenario

Load testing went badly. The API (`lab-a04-api.service`) logs **"Too many open files"**,
the batch user's jobs hit limits, and the network team sent a list of kernel settings for
high-connection servers. Apply everything **persistently** - a reboot must not undo it.

## Tasks

1. Fix `lab-a04-api.service` so it can hold its 3000 open files: raise its open-file limit to
   **8192** using a **drop-in override** (not by editing the unit file), then restart it.
   Its status is in `/run/lab-a04/status` and the journal.
2. For the user `batch` (already exists), set in `/etc/security/limits.d/batch.conf`:
   open files soft **4096** / hard **8192**, max user processes soft and hard **2048**.
3. In `/etc/sysctl.d/90-lab.conf` set, and apply now:
   | key | value |
   |---|---|
   | `net.core.somaxconn` | `8192` |
   | `net.ipv4.tcp_fin_timeout` | `15` |
   | `net.ipv4.ip_local_port_range` | `10240 65000` |
   | `vm.swappiness` | `10` |

## Commands to learn

`ulimit -a` `ulimit -Sn` / `-Hn` `prlimit --pid PID` `cat /proc/PID/limits`
`systemctl edit UNIT` `systemctl show -p LimitNOFILE` `/etc/security/limits.conf` `pam_limits`
`sysctl -a` `sysctl -w` `sysctl --system` `sysctl -p FILE` `/proc/sys/...` `ls /proc/PID/fd | wc -l`

## Done when

`lab check a04` passes.

## Explore (not graded)

- Why don't `/etc/security/limits.conf` settings apply to systemd services? (Hint: PAM sessions.)
- `cat /proc/$(systemctl show -p MainPID --value lab-a04-api)/limits` before and after.
- What does `somaxconn` actually limit? Look at the `Recv-Q`/`Send-Q` columns of `ss -ltn`.
- In a container some sysctls are per-network-namespace (`net.*`), others are host-wide (`vm.*`).
  What does that mean for Kubernetes pods asking for sysctls?
