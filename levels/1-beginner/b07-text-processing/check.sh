#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
L=/opt/lab/b07
LOG=$L/access.log

top_of() { sort | uniq -c | sort -k1,1nr -k2 | awk 'NR == 1 {print $2}'; }

section "Access log"
check_answer_is "1. total requests" b07 total "$(wc -l < "$LOG")"
check_answer_is "2. top client IP" b07 topip "$(awk '{print $1}' "$LOG" | top_of)"
check_answer_is "3. number of 404 responses" b07 404 "$(awk '$9 == 404' "$LOG" | wc -l)"
check_answer_is "4. unique client IPs" b07 uniqueips "$(awk '{print $1}' "$LOG" | sort -u | wc -l)"
check_answer_is "5. path with the most 500s" b07 top500path "$(awk '$9 == 500 {print $7}' "$LOG" | top_of)"

section "Users CSV"
check_answer_is "6. active platform emails, sorted" b07 platform \
  "$(awk -F, 'NR > 1 && $3 == "platform" && $4 == "yes" {print $2}' "$L/users.csv" | sort)"

finish
