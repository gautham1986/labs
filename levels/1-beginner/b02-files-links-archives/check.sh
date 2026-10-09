#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
L=/opt/lab/b02

tar_has_relative_release() {
  local list; list=$(tar -tzf "$L/backup/release.tar.gz") || return 1
  grep -qx 'release-1.4.2/bin/app' <<< "$list" && ! grep -q '^/' <<< "$list" && ! grep -q '^opt/' <<< "$list"
}
not_symlink() { [[ -f "$1" && ! -L "$1" ]]; }
mtime_preserved() {
  [[ "$(stat -c %Y "$L/release-1.4.2/bin/app")" == "$(stat -c %Y "$L/release-1.4.3/bin/app")" ]] &&
  [[ "$(stat -c %a "$L/release-1.4.2/lib/mod2.sh")" == "$(stat -c %a "$L/release-1.4.3/lib/mod2.sh")" ]]
}

section "Links"
check "current is a symlink to release-1.4.2" link_to "$L/current" "$L/release-1.4.2"
check "config/app.conf.hard is a hard link (same inode) to app.conf" same_inode "$L/config/app.conf" "$L/config/app.conf.hard"
check "config/app.conf.hard is a regular file, not a symlink" not_symlink "$L/config/app.conf.hard"

section "Archives"
check "backup/release.tar.gz is a valid gzip tarball" tar -tzf "$L/backup/release.tar.gz"
check "tarball paths are relative (release-1.4.2/...)" tar_has_relative_release
check "bundle extracted to extracted/vendor-sdk/" file_exists "$L/extracted/vendor-sdk/docs/LICENSE"

section "Copies"
check "release-1.4.3 exists with the same files" diff -r "$L/release-1.4.2" "$L/release-1.4.3"
check "release-1.4.3 kept permissions and timestamps" mtime_preserved

section "Answers"
check_answer_is "file type of bin/app" b02 filetype "$(file -b "$L/release-1.4.2/bin/app" | awk '{print $1}')"

finish
