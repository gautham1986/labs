#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=extcount.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks

R="$TMPD/tree"
mkdir -p "$R/a/b" "$R/with space" "$R/dir.d"
touch "$R/one.py" "$R/a/two.py" "$R/a/b/three.PY" "$R/README.md" "$R/a/notes.md" "$R/Makefile" \
      "$R/.bashrc" "$R/a/archive.tar.gz" "$R/with space/my file.txt" "$R/a/b/x.txt" "$R/dir.d/conf"
touch "$R/a/new"$'\n'"line.txt"
# (none): Makefile, .bashrc, dir.d/conf | py: 3 | txt: 3 (incl. a name with a newline) | md: 2 | gz: 1
EXPECTED=$'3 (none)\n3 py\n3 txt\n2 md\n1 gz'

section "Counting"
t "counts by extension, sorted by count then name" '[[ "$(S "$R")" == "$EXPECTED" ]]'
t "extensions are lower-cased (.PY counts as py)"  'S "$R" | grep -qx "3 py"'
t "dotfiles and extension-less files are (none)"  'S "$R" | grep -qx "3 (none)"'
t "uses the last dot (archive.tar.gz -> gz)"      'S "$R" | grep -qx "1 gz"'
t "directories are not counted (dir.d)"           '! S "$R" | grep -q " d$"'
t "names with spaces and newlines are handled"    'S "$R" | grep -qx "3 txt"'
t "empty directory -> no output, exit 0"          'mkdir -p empty && [[ -z "$(S empty)" ]]'

section "Errors"
t "missing dir -> exit 2"           'S /nonexistent >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "file instead of dir -> exit 2"   'S "$R/one.py" >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "no args -> exit 2"               'S >/dev/null 2>&1; [[ $? -eq 2 ]]'
done_testing
