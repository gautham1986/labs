#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
pkill -9 -x jail-sleep 2>/dev/null; pkill -9 -f /opt/lab/e04/bin/memhog 2>/dev/null
sleep 0.5
CG=/sys/fs/cgroup/lab-e04
if [[ -d "$CG" ]]; then
  # move any leftovers to the root cgroup, then remove
  while read -r p; do echo "$p" > /sys/fs/cgroup/cgroup.procs 2>/dev/null; done < "$CG/cgroup.procs"
  rmdir "$CG" 2>/dev/null || warn "could not remove $CG (processes still inside?)"
fi
rm -rf /opt/lab/e04
exit 0
