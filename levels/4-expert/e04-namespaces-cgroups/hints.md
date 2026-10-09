cgroup v2 is one tree at `/sys/fs/cgroup`. A child only gets controllers that its parent lists in
`cgroup.subtree_control`. Check: `cat /sys/fs/cgroup/cgroup.subtree_control` - you need
`cpu memory pids`. If missing: `echo '+cpu +memory +pids' | sudo tee /sys/fs/cgroup/cgroup.subtree_control`.
---
Creating a cgroup is just `sudo mkdir /sys/fs/cgroup/lab-e04`. Limits are files:
`echo 64M | sudo tee /sys/fs/cgroup/lab-e04/memory.max`, same idea for `memory.swap.max`,
`pids.max` and `cpu.max`.
---
A process joins a cgroup when you write its PID to `cgroup.procs`, and children inherit the
cgroup. Easiest: start a root shell, move *the shell* into the cgroup, then run the program:
`sudo bash -c 'echo $$ > /sys/fs/cgroup/lab-e04/cgroup.procs; exec /opt/lab/e04/bin/memhog'`
---
Namespaces: `unshare --fork --pid --mount-proc --uts --mount bash -c 'hostname jail; exec /opt/lab/e04/bin/jail-sleep infinity'`
`--fork` is needed so the new process becomes PID 1 of the new PID namespace.
Combine with the cgroup trick and run it in the background with `&` (or `setsid`).
---
Find the host PID with `pgrep -x jail-sleep`, then verify: `grep NSpid /proc/<PID>/status`
(host PID and namespace PID), `sudo nsenter -t <PID> -u hostname`, `cat /proc/<PID>/cgroup`.
