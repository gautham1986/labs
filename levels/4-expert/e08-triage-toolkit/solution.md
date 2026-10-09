# e08 · Solution

```bash
sudo tee /usr/local/bin/triage > /dev/null <<'SCRIPT'
#!/usr/bin/env bash
# triage - capture the state of this host into a tarball for incident response
#   triage [-o OUTDIR] [-h]
set -uo pipefail   # deliberately no -e: a failing collector must not abort the bundle

usage() { echo "usage: triage [-o OUTDIR] [-h]   (default OUTDIR: /var/tmp)"; }

outdir=/var/tmp
while getopts ':o:h' opt; do
  case $opt in
    o) outdir=$OPTARG ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
mkdir -p "$outdir" || { echo "cannot create $outdir" >&2; exit 1; }

name="triage-$(hostname)-$(date +%Y%m%d-%H%M%S)"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
d="$tmp/$name"
mkdir "$d"

# run <cmd...>: header + output, never hangs longer than 10s, never fails the script
run() { echo "### $*"; timeout 10 "$@" 2>&1 || echo "(exit $?)"; echo; }

{ run hostname; run uname -a; run cat /etc/os-release; run uptime; } > "$d/system.txt"
{ run nproc; run cat /proc/loadavg; run free -m; run vmstat 1 3; } > "$d/cpu-mem.txt"
{ run df -hT; run df -i; run lsblk; } > "$d/disk.txt"
{ run ps -eo pid,ppid,user,pcpu,pmem,etime,stat,comm --sort=-pcpu --lines 16
  run ps -eo pid,ppid,user,pcpu,pmem,rss,etime,comm --sort=-pmem --lines 16; } > "$d/processes.txt"
{ run ip -br addr; run ip route; run ss -tulpn; run ss -s; } > "$d/network.txt"
{ run systemctl --failed --no-pager; run systemctl list-timers --no-pager
  run systemctl list-units --type=service --state=running --no-pager; } > "$d/services.txt"
{ run journalctl -p err -b --no-pager -n 200; run dmesg -T --level=err,warn; } > "$d/logs.txt"

# --- automatic findings ---
{
  df -P | awk 'NR > 1 { u = $5; sub("%", "", u); if (u + 0 >= 90) print "WARN disk: " $6 " at " u "%" }'
  df -Pi 2>/dev/null | awk 'NR > 1 && $5 != "-" { u = $5; sub("%", "", u); if (u + 0 >= 90) print "WARN inodes: " $6 " at " u "%" }'
  systemctl --failed --plain --no-legend 2>/dev/null | awk 'NF { print "WARN unit: " $1 " failed" }'
  awk -v n="$(nproc)" '{ if ($1 > n) print "WARN load: load1 " $1 " > " n " CPUs" }' /proc/loadavg
  oom=$(dmesg 2>/dev/null | grep -ci 'killed process' || true)
  (( ${oom:-0} > 0 )) && echo "WARN oom: $oom OOM kills in the kernel log"
} > "$d/summary.txt"
[[ -s "$d/summary.txt" ]] || echo "OK: no findings" > "$d/summary.txt"

tar -czf "$outdir/$name.tar.gz" -C "$tmp" "$name"
cat "$d/summary.txt"
echo "$outdir/$name.tar.gz"
SCRIPT
sudo chmod 755 /usr/local/bin/triage
shellcheck /usr/local/bin/triage

sudo triage -o /tmp
```

## Why

- `set -e` is great for scripts that must stop on error; a *diagnostic* tool is the opposite -
  collect everything you can. Wrap each command instead.
- `timeout` protects you from the very problems you're diagnosing (hung NFS, stuck D-state disks).
- A summary with obvious findings first turns a 5 MB bundle into a 5-second read.
