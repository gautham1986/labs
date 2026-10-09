# a06 · Debugging a black box with strace

**Level:** Advanced · **Time:** ~40 min · **Needs:** systemd, strace

## Scenario

🚨 *"report-svc is DEGRADED."* It's a vendor binary (well, pretend it is - no peeking at the
source) and its logs are useless:

```
$ journalctl -u report-svc -n 3 -o cat
DEGRADED: configuration not found
```

Not found *where*? The vendor docs (`/opt/lab/a06/OPS-NOTES.txt`) are two years out of date.
You'll have to ask the kernel what the program is actually doing.

## Tasks

1. Find out which file `report-svc` is looking for. Write its **full path** to
   `~/answers/a06-file.txt`, then create it so the service accepts it (the ops notes describe
   the content).
2. The next error is just as vague. Find out which **TCP port** it is trying to reach and write
   it to `~/answers/a06-port.txt`.
3. The dependency is `minicache` (`/opt/lab/a06/bin/minicache --help`). Run it as a proper
   **systemd service** named `minicache.service` (enabled, restarts on failure) on the port
   `report-svc` expects.
4. `report-svc` reports `OK` (`cat /run/report-svc/status`).

Rules: don't read `/opt/lab/a06/*.py` - treat it as a binary.

## Commands to learn

`strace -p PID` `strace -f -e trace=openat,connect -p PID` `strace -e trace=%file,%network`
`strace -s 200` `strace -c` (syscall summary) `strace -o out.txt` `ltrace` `lsof -p PID`
`ls -l /proc/PID/fd` `cat /proc/PID/environ | tr '\0' '\n'` `systemctl show -p MainPID`

## Done when

`lab check a06` passes.

## Explore (not graded)

- `strace -c -p PID` for 10 seconds: which syscalls dominate? What would a busy-looping
  program look like?
- `strace -f -e trace=execve bash -c 'ls | wc -l'` - see every program a shell pipeline runs.
- `strace -T -e trace=connect curl -s https://example.com` - how long did each connect take?
- Why does strace need root (or `ptrace` permissions) to attach to another user's process?
  Look up `kernel.yama.ptrace_scope`.
