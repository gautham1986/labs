#!/usr/bin/env bash
# healthcheck.sh - run http/tcp checks from a file, in parallel
# usage: healthcheck.sh [-t SECONDS] [-j] FILE
set -uo pipefail

usage() { echo "usage: healthcheck.sh [-t SECONDS] [-j] FILE" >&2; exit 2; }

timeout_s=3 json=0
while getopts ':t:j' opt; do
  case $opt in
    t) timeout_s=$OPTARG ;;
    j) json=1 ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
(( $# == 1 )) || usage
[[ "$timeout_s" =~ ^[1-9][0-9]*$ ]] || usage
file=$1
[[ -r "$file" ]] || { echo "healthcheck.sh: cannot read $file" >&2; exit 2; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

check_http() {
  local code
  code=$(curl -s -o /dev/null -m "$timeout_s" -w '%{http_code}' "$1") || true
  case $code in
    2??|3??) echo ok ;;
    000) echo "fail no response" ;;
    *) echo "fail HTTP $code" ;;
  esac
}
check_tcp() {
  local host=${1%:*} port=${1##*:}
  [[ "$port" =~ ^[0-9]+$ && "$host" != "$1" ]] || { echo "fail bad target"; return; }
  if timeout "$timeout_s" bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$host" "$port" 2>/dev/null; then
    echo ok
  else
    echo "fail cannot connect"
  fi
}

types=() targets=() n=0
while read -r type target _; do
  [[ -z "${type:-}" || "$type" == \#* ]] && continue
  types+=("$type"); targets+=("${target:-}")
  case $type in
    http) check_http "${target:-}" > "$work/$n" & ;;
    tcp)  check_tcp "${target:-}" > "$work/$n" & ;;
    *)    echo "fail unknown check type" > "$work/$n" ;;
  esac
  n=$((n + 1))
done < "$file"
wait

rc=0
for (( i = 0; i < n; i++ )); do       # no pipeline here: rc must survive the loop
  read -r verdict reason < "$work/$i"
  if [[ "$verdict" == ok ]]; then ok=true; else ok=false; rc=1; fi
  if (( json )); then
    jq -cn --arg type "${types[i]}" --arg target "${targets[i]}" --argjson ok "$ok" \
      '{type: $type, target: $target, ok: $ok}'
  elif [[ $ok == true ]]; then
    printf 'OK   %s %s\n' "${types[i]}" "${targets[i]}"
  else
    printf 'FAIL %s %s (%s)\n' "${types[i]}" "${targets[i]}" "${reason:-failed}"
  fi
done > "$work/results"

if (( json )); then jq -cs . "$work/results"; else cat "$work/results"; fi
exit "$rc"
