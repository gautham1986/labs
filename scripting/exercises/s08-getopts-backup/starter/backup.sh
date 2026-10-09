#!/usr/bin/env bash
# backup.sh - timestamped tar.gz backups with retention
# usage: backup.sh -s SRC -d DEST [-k KEEP] [-n] [-h]
set -euo pipefail

usage() { echo "usage: backup.sh -s SRC -d DEST [-k KEEP] [-n] [-h]"; }

src="" dest="" keep=3 dry=0
# TODO: parse options with getopts (':s:d:k:nh'); -h -> usage + exit 0; bad option -> usage >&2 + exit 2
# TODO: validate: src and dest set, keep is a positive integer (exit 2), src is a directory (exit 1)
# TODO: build the archive name with date +%Y%m%d-%H%M%S and create it (or print "would create")
# TODO: list this source's archives oldest-first, delete all but the newest $keep

echo "TODO $src $dest $keep $dry"
