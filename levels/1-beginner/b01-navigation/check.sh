#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

H=$(user_home)

section "Answers"
check_answer "secret code from the hidden .treasure file" b01 secret
check_answer "number of regular *.log files" b01 logcount
check_answer "absolute path of the largest file" b01 largest

section "Project skeleton"
for d in src tests docs config; do
  check "~/projects/webapp/$d exists" dir_exists "$H/projects/webapp/$d"
done
check "~/projects/webapp/README.md exists" file_exists "$H/projects/webapp/README.md"
check "~/projects/webapp is owned by $LAB_USER (not root)" owner_is "$H/projects/webapp" "$LAB_USER"

finish
