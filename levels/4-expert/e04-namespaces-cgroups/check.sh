#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
CG=/sys/fs/cgroup/lab-e04

file_is() { [[ "$(cat "$CG/$1" 2>/dev/null)" == "$2" ]]; }
swap_off() { [[ -d "$CG" ]] && { [[ ! -e "$CG/memory.swap.max" ]] || file_is memory.swap.max 0; }; }
oom_killed() { (( $(awk '$1 == "oom_kill" {print $2}' "$CG/memory.events" 2>/dev/null || echo 0) >= 1 )); }

PID=$(normalize < "$(answer_path e04 pid)" 2>/dev/null)
is_jail() { [[ -n "$PID" && -d /proc/$PID && "$(cat /proc/$PID/comm)" == jail-sleep ]]; }
own_ns() { [[ "$(readlink /proc/$PID/ns/$1)" != "$(readlink /proc/1/ns/$1)" ]]; }
pid1_inside() { [[ "$(awk '/^NSpid:/ {print $NF}' /proc/$PID/status)" == 1 ]]; }
hostname_jail() { [[ "$(nsenter -t "$PID" -u hostname)" == jail ]]; }
in_cgroup() { grep -q '^0::/lab-e04$' /proc/$PID/cgroup; }
proc_remounted() { [[ "$(nsenter -t "$PID" -p -m ps -e --no-headers | wc -l)" -le 3 ]]; }

section "Part A - cgroup /sys/fs/cgroup/lab-e04"
check "cgroup exists" dir_exists "$CG"
check "memory.max = 64 MiB" file_is memory.max 67108864
check "memory.swap.max = 0" swap_off
check "pids.max = 32" file_is pids.max 32
check "cpu.max = 50000 100000" file_is cpu.max "50000 100000"
check "memhog was OOM-killed inside it (memory.events oom_kill >= 1)" oom_killed

section "Part B - jail-sleep in namespaces"
check "~/answers/e04-pid.txt holds the host PID of a running jail-sleep" is_jail
if is_jail; then
  check "own PID namespace" own_ns pid
  check "it is PID 1 inside its namespace" pid1_inside
  check "/proc remounted (ps inside sees only the jail)" proc_remounted
  check "own UTS namespace with hostname 'jail'" hostname_jail
  check "own mount namespace" own_ns mnt
  check "runs inside the lab-e04 cgroup" in_cgroup
fi

finish
