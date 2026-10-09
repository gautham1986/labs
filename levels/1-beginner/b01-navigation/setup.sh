#!/usr/bin/env bash
# b01 setup: build a directory maze with a hidden treasure, .log files and one big file
source "$LAB_ROOT/lib/common.sh"
need_root

L=/opt/lab/b01
M=$L/maze
rm -rf "$L"
mkdir -p "$M"
prepare_answers

dirs=()
for a in north south east west; do
  for b in alpha beta gamma delta; do
    for c in 1 2 3; do
      dirs+=("$M/$a/$b/level-$c")
    done
  done
done
dirs+=("$M/west/my documents" "$M/east/archive.log" "$M/south/.cache/tmp")
mkdir -p "${dirs[@]}"

pick() { echo "${dirs[RANDOM % ${#dirs[@]}]}"; }

# .log files (random count), plus decoys that are NOT regular *.log files
nlogs=$((17 + RANDOM % 23))
for ((i = 1; i <= nlogs; i++)); do
  d=$(pick); f="$d/app-$i.log"
  while [[ -e "$f" ]]; do d=$(pick); f="$d/app-$i-$RANDOM.log"; done
  printf '%s INFO request served in %dms\n' "$(date -u +%FT%TZ)" $((RANDOM % 900)) > "$f"
done
for ((i = 1; i <= 8; i++)); do
  d=$(pick)
  echo "rotated" > "$d/app-$i.log.1"
  echo "notes" > "$d/notes-$i.txt"
done
echo "this is a directory named like a log file" > "$M/east/archive.log/README"
echo "important" > "$M/west/my documents/budget 2024.txt"

# Random-sized filler files and one clearly largest file
for ((i = 1; i <= 30; i++)); do
  head -c $((RANDOM * 20)) /dev/urandom > "$(pick)/blob-$i.bin"
done
big="$(pick)/core.$((1000 + RANDOM % 9000))"
head -c $(( (3 + RANDOM % 3) * 1024 * 1024 )) /dev/urandom > "$big"

# The treasure (and a decoy that is not hidden)
code="LNX-$(od -An -N3 -tx1 /dev/urandom | tr -d ' \n' | tr 'a-f' 'A-F')"
tdir=$(pick)
while [[ "$tdir" == *"my documents"* || "$tdir" == *archive.log* ]]; do tdir=$(pick); done
printf '# you found it!\nSECRET=%s\n' "$code" > "$tdir/.treasure"
echo "SECRET=not-this-one-it-is-not-hidden" > "$(pick)/treasure.txt"

chmod -R a+rX "$L"

expect_set b01 secret "$code"
expect_set b01 logcount "$nlogs"
expect_set b01 largest "$big"

rm -rf "$(user_home)/projects/webapp"

