#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

nice_is() { local p; p=$(pid_of "$1"); [[ -n "$p" && "$(ps -o ni= -p "$p" | tr -d ' ')" == "$2" ]]; }
reloaded() { [[ -s /run/lab/b06-reloads ]] && (( $(cat /run/lab/b06-reloads) >= 1 )); }

section "CPU hog"
check_answer_is "name of the CPU hog" b06 hog cpu-burner
check "cpu-burner is no longer running" process_absent cpu-burner

section "Batch job"
check "report-gen is still running" process_running report-gen
check "report-gen has niceness 15" nice_is report-gen 15

section "Zombie"
check_answer "PID of the zombie's parent" b06 zparent
check "the zombie's parent (lazy-parent) is gone" process_absent lazy-parent

section "Signals"
check "config-watcher is still running" process_running config-watcher
check "config-watcher reloaded its config (got SIGHUP)" reloaded

finish
