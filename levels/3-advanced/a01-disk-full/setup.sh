#!/usr/bin/env bash
# a01 setup: a nearly full volume (with a deleted-but-open file) and an inode-exhausted volume
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd lsof
prepare_answers
bash "$LAB_DIR/cleanup.sh"

V=/srv/a01 S=/srv/a01-sessions
mkdir -p "$V" "$S"
mount -t tmpfs -o size=64M,mode=0755 a01-data "$V" || die "could not mount tmpfs (need root / privileged container)"
mount -t tmpfs -o size=16M,nr_inodes=1024,mode=0755 a01-sessions "$S" || die "could not mount tmpfs"

mkdir -p "$V"/app/{data,logs/old,cache}
for f in customers.db orders.db config.json; do head -c 700K /dev/urandom > "$V/app/data/$f"; done
mkdir -p "$LAB_VAR/a01"
( cd "$V/app/data" && sha256sum ./* ) > "$LAB_VAR/a01/data.sha256"

head -c 26M /dev/urandom | base64 -w 120 | head -c 26M > "$V/app/logs/debug.log"
for i in 1 2 3 4; do head -c 1M /dev/urandom > "$V/app/logs/old/debug.log.$i.gz"; done
for i in $(seq 1 200); do head -c 40K /dev/urandom > "$V/app/cache/obj-$i.bin"; done

# a process keeps a 20M file open, then the file is deleted
head -c 20M /dev/urandom > "$V/app/logs/trace.log"
clone_bin tail /opt/lab/a01/bin/log-shipper
spawn log-shipper /opt/lab/a01/bin/log-shipper -f "$V/app/logs/trace.log"
sleep 0.5
rm -f "$V/app/logs/trace.log"

# sessions: mostly stale, some fresh
mkdir -p "$S/sessions"
i=0
while touch "$S/sessions/sess_$i" 2>/dev/null; do
  (( i % 10 == 0 )) || touch -d '3 days ago' "$S/sessions/sess_$i"
  i=$((i + 1))
done
find "$S/sessions" -type f -mtime -1 | sort > "$LAB_VAR/a01/fresh-sessions"

df -h "$V"; df -i "$S"
