Skeleton:
```
#!/usr/bin/env bash
set -uo pipefail                      # no -e: one failing collector must not abort everything
usage() { echo "usage: triage [-o OUTDIR] [-h]"; }
outdir=/var/tmp
while getopts ':o:h' opt; do
  case $opt in
    o) outdir=$OPTARG ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
```
---
Collect into a temp dir, then archive and clean up:
```
name="triage-$(hostname)-$(date +%Y%m%d-%H%M%S)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/$name"
run() { echo "### $*"; timeout 10 "$@" 2>&1; echo; }
{ run hostname; run uname -a; ... } > "$tmp/$name/system.txt"
tar -czf "$outdir/$name.tar.gz" -C "$tmp" "$name"
echo "$outdir/$name.tar.gz"
```
---
Disk findings: `df -P | awk 'NR > 1 { u = $5; sub("%", "", u); if (u + 0 >= 90) print "WARN disk: " $6 " at " u "%" }'`
---
Failed units: `systemctl --failed --plain --no-legend | awk '{print "WARN unit: " $1 " failed"}'`
Load vs CPUs: compare `cut -d' ' -f1 /proc/loadavg` with `nproc` using awk (floating point).
