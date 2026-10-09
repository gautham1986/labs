#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
S=/usr/local/bin/snapshot-backup B=/backup/a08 D=/srv/a08/data

snapshots() { find "$B" -mindepth 1 -maxdepth 1 -type d -regextype egrep -regex '.*/[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{6}' 2>/dev/null | sort; }
two_snaps() { (( $(snapshots | wc -l) >= 2 )); }
latest_ok() { [[ -L "$B/latest" && "$(readlink -f "$B/latest")" == "$(snapshots | tail -1)" ]]; }
hardlinked() {
  local a b; a=$(snapshots | tail -2 | head -1); b=$(snapshots | tail -1)
  same_inode "$a/config/app.yaml" "$b/config/app.yaml"
}
manifest_ok() { [[ -s "$B/latest/SHA256SUMS" ]] && (cd "$B/latest" && sha256sum --quiet -c SHA256SUMS) && ! grep -q ' \./SHA256SUMS$' "$B/latest/SHA256SUMS"; }
strict_mode() { grep -Eq 'set -[a-z]*e[a-z]*u[a-z]*o pipefail|set -euo pipefail' "$S"; }
lint_ok() { command -v shellcheck >/dev/null || return 0; shellcheck -S warning "$S"; }
restored_content() { [[ -f "$LAB_VAR/a08/disaster-ran" ]] && [[ "$(cd "$D" && find . -type f -print0 | sort -z | xargs -0 sha256sum)" == "$(cat "$LAB_VAR/a08/sums")" ]]; }
restored_meta() { [[ -f "$LAB_VAR/a08/disaster-ran" ]] && [[ "$(cd "$D" && find . -printf '%y %m %u %g %p %l\n' | sort)" == "$(cat "$LAB_VAR/a08/meta")" ]]; }
retention() {
  local _
  for _ in 1 2 3 4 5 6; do sleep 1.1; "$S" >/dev/null 2>&1 || return 1; done
  (( $(snapshots | wc -l) == 5 )) && latest_ok && manifest_ok
}

section "Backup script"
check "$S exists and is executable" is_executable "$S"
check "uses set -euo pipefail" strict_mode
check "passes shellcheck" lint_ok

section "Snapshots"
check "at least 2 snapshots named YYYY-MM-DD_HHMMSS" two_snaps
check "latest -> newest snapshot" latest_ok
check "unchanged files are hard-linked between snapshots" hardlinked
check "SHA256SUMS in latest verifies (and excludes itself)" manifest_ok

section "Disaster recovery"
check "the disaster happened (sudo a08-disaster)" file_exists "$LAB_VAR/a08/disaster-ran"
check "restored file contents match the original exactly" restored_content
check "restored modes, owners, symlinks match (nothing extra)" restored_meta

section "Retention (runs your script 6 more times)"
if is_executable "$S" && two_snaps; then
  check "keeps exactly the 5 newest snapshots" retention
else
  check "keeps exactly the 5 newest snapshots" false
fi

finish
