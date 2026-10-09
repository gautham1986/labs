`top` sorts by CPU by default. Or non-interactively:
`ps -eo pid,ppid,ni,pcpu,stat,comm --sort=-pcpu | head`
---
`renice -n 15 -p PID` (only root can *lower* niceness). `pgrep -x report-gen` gives you the PID.
---
Zombies show `Z` in the STAT column. `ps -eo pid,ppid,stat,comm | awk '$3 ~ /Z/'` shows them
with their parent PID (PPID). A zombie is already dead - it's waiting for its parent to
collect its exit status. You can't kill it, but if the parent dies, init adopts and reaps it.
---
`kill -HUP PID` or `pkill -HUP -x config-watcher`. Check the log file to confirm it reloaded.
Don't use plain `kill` (that's SIGTERM, which ends the process).
