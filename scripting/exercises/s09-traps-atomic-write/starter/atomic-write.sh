#!/usr/bin/env bash
# atomic-write.sh - atomically replace a file with stdin
# usage: some-command | atomic-write.sh [-e] [-m MODE] TARGET
set -euo pipefail

# TODO: parse -e and -m MODE; TARGET is required (exit 2)
# TODO: create the temp file next to TARGET with mktemp
# TODO: trap: remove the temp file on EXIT; on INT/TERM exit with 130/143
# TODO: copy stdin to the temp file; refuse empty content unless -e
# TODO: set the mode, then mv the temp file over TARGET

cat > "${!#}"   # NOT atomic - replace me
