#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=backup.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks
mkdir -p "$TMPD/data/sub" "$TMPD/other"
echo hello > "$TMPD/data/a.txt"; echo world > "$TMPD/data/sub/b.txt"
count() { find "$TMPD/out" -maxdepth 1 -name 'data-*.tar.gz' 2>/dev/null | wc -l; }

section "Creating archives"
t "creates DEST and an archive, prints 'created PATH'" 'S -s data -d out | grep -Eq "^created out/data-[0-9]{8}-[0-9]{6}\.tar\.gz$" && [[ $(count) -eq 1 ]]'
t "archive paths are relative (data/...)" 'tar -tzf "$(ls out/data-*.tar.gz | head -1)" | grep -qx "data/sub/b.txt" && ! tar -tzf "$(ls out/data-*.tar.gz | head -1)" | grep -q "^/"'
t "trailing slash on SRC works"           'sleep 1.1; S -s data/ -d out | grep -q "^created out/data-"'

section "Retention"
t "keeps only the newest KEEP archives"   'sleep 1.1; touch out/unrelated.txt out/other-20200101-000000.tar.gz; S -s data -d out -k 2 > r.txt; [[ $(count) -eq 2 ]]'
t "prints 'deleted PATH' for removed ones" 'grep -q "^deleted out/data-" r.txt'
t "never touches other files in DEST"     '[[ -f out/unrelated.txt && -f out/other-20200101-000000.tar.gz ]]'

section "Dry run"
t "-n changes nothing"                    'before=$(ls out | sort); sleep 1.1; S -n -s data -d out -k 1 >/dev/null; [[ "$(ls out | sort)" == "$before" ]]'
t "-n says what it would do"              'S -n -s data -d out -k 1 > d.txt; grep -q "^would create out/data-" d.txt && grep -q "^would delete out/data-" d.txt'

section "Errors"
t "-h -> usage on stdout, exit 0"         'S -h | grep -qi usage'
t "missing -d -> exit 2"                  'S -s data >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "unknown option -> exit 2"              'S -x -s data -d out >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "-k 0 -> exit 2"                        'S -s data -d out -k 0 >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "SRC not a directory -> exit 1"         'S -s nope -d out >/dev/null 2>&1; [[ $? -eq 1 ]]'
done_testing
