#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
kill_spawned cpu-burner report-gen config-watcher lazy-parent
for p in cpu-burner report-gen config-watcher lazy-parent; do kill_by_name "$p"; done
rm -f /run/lab/b06-reloads
exit 0
