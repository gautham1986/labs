# e08 · On-call triage toolkit

**Level:** Expert · **Time:** ~75 min · **Needs:** systemd

## Scenario

Every incident starts the same way: someone SSHes in and types the same 20 commands, half of
which scroll away. Build the tool you wish you'd had on your first night on call: **one command
that captures the state of a box** into a bundle you can attach to the incident, plus a summary
that points at the obvious problems.

The setup leaves a couple of real problems on this box for your tool to find.

## Tasks

Write `/usr/local/bin/triage` (bash):

- **Usage:** `triage [-o OUTDIR] [-h]`. Default `OUTDIR` is `/var/tmp`. `-h` prints usage and exits 0;
  an unknown option prints usage to stderr and exits **2**.
- Creates `OUTDIR/triage-<hostname>-<YYYYmmdd-HHMMSS>.tar.gz` containing a directory
  `triage-<hostname>-<YYYYmmdd-HHMMSS>/` with these **non-empty** files:

  | file | contents (at least) |
  |---|---|
  | `system.txt` | `hostname`, `uname -a`, `/etc/os-release`, `uptime` |
  | `cpu-mem.txt` | `nproc`, load, `free -m`, `vmstat 1 3` |
  | `disk.txt` | `df -hT`, `df -i`, `lsblk` |
  | `processes.txt` | top 15 by CPU and top 15 by memory (`ps`) |
  | `network.txt` | `ip -br addr`, `ip route`, `ss -tulpn`, `ss -s` |
  | `services.txt` | `systemctl --failed`, recently started units/timers |
  | `logs.txt` | errors from the journal this boot (last 200), `dmesg` tail if readable |
  | `summary.txt` | **automatic findings**, one per line, starting with `WARN` (see below) |

- `summary.txt` must flag at least:
  - every filesystem at **≥ 90 %** usage, e.g. `WARN disk: /srv/e08 at 95%`
  - every **failed systemd unit**, e.g. `WARN unit: foo.service failed`
  - load average (1 min) above the number of CPUs
  - and say `OK: no findings` when there are none.
- Prints the bundle path as the **last line** of output, finishes in **< 30 s**, exits 0 even if a
  single collector command fails (one missing tool must not kill the whole bundle), cleans up its
  temp directory, and passes `shellcheck`.

## Commands to learn

`getopts` `mktemp -d` `trap 'rm -rf "$tmp"' EXIT` `tar -czf X -C DIR name` `df -P` `systemctl --failed --plain --no-legend`
`ps -eo pid,user,pcpu,pmem,etime,comm --sort=-pcpu` `journalctl -p err -b --no-pager -n 200` `timeout 5 cmd`

## Done when

`lab check e08` passes.

## Explore (not graded)

- Add `-q` (quiet) and `-s HOST` (run remotely over SSH and fetch the bundle) options.
- Wrap each collector in `timeout 5` - what happens to your tool when NFS hangs and `df` blocks forever?
- Compare with Brendan Gregg's "Linux Performance Analysis in 60,000 Milliseconds" checklist and
  add what's missing (`mpstat -P ALL`, `pidstat`, `iostat -xz`, `sar -n DEV`).
