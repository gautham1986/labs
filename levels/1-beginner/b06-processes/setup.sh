#!/usr/bin/env bash
# b06 setup: a CPU hog, a batch job, a zombie, and a daemon that reloads on SIGHUP
source "$LAB_ROOT/lib/common.sh"
need_root
prepare_answers
bash "$LAB_DIR/cleanup.sh"

B=/opt/lab/b06/bin
clone_bin yes   "$B/cpu-burner"
clone_bin sleep "$B/report-gen"
clone_bin sleep "$B/lazy-parent"
cat > "$B/config-watcher" <<'SCRIPT'
#!/bin/bash
# Pretend daemon: reloads its "config" on SIGHUP
n=0
log=/var/log/b06-config-watcher.log
echo "$(date '+%F %T') config-watcher started (pid $$)" >> "$log"
trap 'n=$((n + 1)); echo "$n" > /run/lab/b06-reloads; echo "$(date "+%F %T") SIGHUP received - config reloaded ($n)" >> "$log"' HUP
while :; do sleep 1 & wait $!; done
SCRIPT
chmod 755 "$B/config-watcher"
rm -f /run/lab/b06-reloads /var/log/b06-config-watcher.log

spawn cpu-burner "$B/cpu-burner"
spawn report-gen "$B/report-gen" infinity
spawn config-watcher "$B/config-watcher"
# The child sleep exits after 0.2s, but its parent (which exec'd into lazy-parent) never wait()s
spawn lazy-parent bash -c "/bin/sleep 0.2 & exec $B/lazy-parent infinity"
sleep 0.5
expect_set b06 zparent "$(spawned_pid lazy-parent)"
