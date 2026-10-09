# e04 · Containers from scratch: namespaces & cgroups

**Level:** Expert · **Time:** ~60 min · **Needs:** root, **cgroup v2** (Ubuntu 22.04+, Docker Desktop, any recent distro)

## Scenario

"Containers are just processes" - prove it. Without Docker, use the two kernel features every
container runtime is built on: **cgroups** (limit what a process can *use*) and **namespaces**
(limit what a process can *see*).

## Tasks

**Part A - cgroups v2 (resource limits)**

1. Create the cgroup `/sys/fs/cgroup/lab-e04` with these limits:
   - memory: **64 MiB** (`memory.max`), and **no swap** (`memory.swap.max` = 0)
   - processes: at most **32** (`pids.max`)
   - CPU: **half a core** (`cpu.max` = `50000 100000`)
2. Run `/opt/lab/e04/bin/memhog` (allocates memory until something stops it) **inside** that cgroup
   and watch the kernel OOM-kill it. The cgroup's `memory.events` must show `oom_kill` ≥ 1.

**Part B - namespaces (isolation)**

3. Start `/opt/lab/e04/bin/jail-sleep infinity` **in the background** so that it:
   - has its own **PID namespace** (it sees itself as PID 1) with `/proc` remounted,
   - has its own **UTS namespace** with hostname **`jail`**,
   - has its own **mount namespace**,
   - and is **inside the `lab-e04` cgroup**.
4. Write the **host** PID of `jail-sleep` to `~/answers/e04-pid.txt`.

## Commands to learn

`cat /sys/fs/cgroup/cgroup.controllers` `cgroup.subtree_control` `mkdir/rmdir` in cgroupfs
`echo PID > cgroup.procs` `memory.current` `memory.events` `cpu.stat` `systemd-cgls` `systemd-cgtop`
`systemd-run --scope -p MemoryMax=64M` `unshare --fork --pid --mount-proc --uts --mount` `nsenter -t PID -a`
`lsns` `readlink /proc/PID/ns/*` `grep NSpid /proc/PID/status` `hostname`

## Done when

`lab check e04` passes. `lab clean e04` kills the jail and removes the cgroup.

## Explore (not graded)

- `sudo nsenter -t <PID> -a ps aux` - what does the "container" see?
- Add a **network namespace** (`--net`): what interfaces exist inside? Connect it to the host with
  a veth pair (lab i07's checker does exactly this).
- Build a real mini-container: `debootstrap` or extract an Alpine minirootfs, then `unshare ... chroot`.
  What's missing compared to Docker? (Image layers, seccomp, capabilities, user namespaces...)
- The systemd way: `sudo systemd-run --scope -p MemoryMax=64M -p TasksMax=32 -p CPUQuota=50% /opt/lab/e04/bin/memhog`
