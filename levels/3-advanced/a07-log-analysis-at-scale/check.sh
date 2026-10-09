#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
[[ -f /opt/lab/a07/app.jsonl ]] || die "run lab start a07 first"

declare -A want
while IFS='=' read -r k v; do want[$k]=$v; done < <(python3 "$LAB_DIR/answers.py" /opt/lab/a07/app.jsonl)

section "Answers"
check_answer_is "1. malformed lines" a07 malformed "${want[malformed]}"
check_answer_is "2. total 5xx responses" a07 5xx "${want[5xx]}"
check_answer_is "3. path with the highest 5xx rate" a07 worst-endpoint "${want[worst-endpoint]}"
check_answer_is "4. p95 latency of /api/checkout" a07 p95 "${want[p95]}"
check_answer_is "5. minute with the most 5xx" a07 spike-minute "${want[spike-minute]}"
check_answer_is "6. client IP with the most 429s" a07 top429 "${want[top429]}"

finish
