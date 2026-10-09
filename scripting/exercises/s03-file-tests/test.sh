#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=fileinfo.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks

# fixtures
mkdir -p "$TMPD/d"; printf 'hello' > "$TMPD/f.txt"; printf '#!/bin/sh\n' > "$TMPD/run.sh"; chmod +x "$TMPD/run.sh"
ln -s f.txt "$TMPD/link"; ln -s nowhere "$TMPD/broken"; mkfifo "$TMPD/pipe"; touch "$TMPD/my file.txt"

section "Types"
t "directory"                 '[[ "$(S d)" == "d: directory" ]]'
t "regular file with size"    '[[ "$(S f.txt)" == "f.txt: file (5 bytes)" ]]'
t "executable file"           '[[ "$(S run.sh)" == "run.sh: executable file (10 bytes)" ]]'
t "symlink shows its target"  '[[ "$(S link)" == "link: symlink -> f.txt" ]]'
t "broken symlink is a symlink, not missing" '[[ "$(S broken)" == "broken: symlink -> nowhere" ]]'
t "fifo is other"             '[[ "$(S pipe)" == "pipe: other" ]]'
t "missing path"              '[[ "$(S nope)" == "nope: missing" ]]'
t "file name with a space"    '[[ "$(S "my file.txt")" == "my file.txt: file (0 bytes)" ]]'

section "Multiple paths & exit codes"
t "one line per path, in order" '[[ "$(S d nope f.txt)" == $'"'"'d: directory\nnope: missing\nf.txt: file (5 bytes)'"'"' ]]'
t "all exist -> exit 0"       'S d f.txt link broken >/dev/null'
t "any missing -> exit 1"     'S d nope >/dev/null; [[ $? -eq 1 ]]'
t "no args -> exit 2"         'S >/dev/null 2>&1; [[ $? -eq 2 ]]'
done_testing
