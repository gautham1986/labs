# e04 · Solution

```bash
CG=/sys/fs/cgroup/lab-e04

# Part A: cgroup with limits
cat /sys/fs/cgroup/cgroup.controllers
echo '+cpu +memory +pids' | sudo tee /sys/fs/cgroup/cgroup.subtree_control > /dev/null
sudo mkdir -p $CG
echo 64M            | sudo tee $CG/memory.max
echo 0              | sudo tee $CG/memory.swap.max
echo 32             | sudo tee $CG/pids.max
echo '50000 100000' | sudo tee $CG/cpu.max

# run memhog inside it; the kernel OOM-kills it at 64M
sudo bash -c "echo \$\$ > $CG/cgroup.procs; exec /opt/lab/e04/bin/memhog" || true
cat $CG/memory.events

# Part B: PID + UTS + mount namespaces, inside the cgroup, in the background
sudo setsid bash -c "echo \$\$ > $CG/cgroup.procs
  exec unshare --fork --pid --mount-proc --uts --mount \
       bash -c 'hostname jail; exec /opt/lab/e04/bin/jail-sleep infinity'" > /dev/null 2>&1 < /dev/null &
sleep 1
PID=$(pgrep -x jail-sleep)
echo "$PID" > ~/answers/e04-pid.txt
grep NSpid /proc/$PID/status          # NSpid: <host pid>  1
sudo nsenter -t "$PID" -u hostname     # jail
cat /proc/$PID/cgroup                  # 0::/lab-e04
sudo nsenter -t "$PID" -p -m ps aux    # it only sees itself
```

## Why

- **cgroups** account and limit resources for a group of processes; children inherit membership.
  Docker's `--memory`, `--pids-limit`, `--cpus` write exactly these files.
- **namespaces** give a process its own view of PIDs, hostname, mounts, network, users, IPC.
- `--mount-proc` is needed because `/proc` shows the PID namespace it was mounted in; without a fresh
  `/proc`, `ps` inside would still list host processes.
- Without `memory.swap.max=0`, a memory-limited process on a box with swap gets slow instead of killed.
