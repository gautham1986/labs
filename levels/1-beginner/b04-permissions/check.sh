#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
L=/srv/b04

all_modes() {  # all_modes <dir> <type d|f> <mode>
  [[ -z "$(find "$1" -type "$2" ! -perm "$3" -print -quit)" ]]
}
acl_has_webdev_read() { getfacl -p "$L/logs/app.log" 2>/dev/null | grep -Eq '^user:webdev:r--'; }
webdev_can_read() { su -s /bin/sh webdev -c "head -c1 $L/logs/app.log"; }
owner_group_mode() { [[ "$(stat -c '%U:%G %a' "$1")" == "$2" ]]; }

section "deploy.sh & secrets"
check "bin/deploy.sh is root:webops 750" owner_group_mode "$L/bin/deploy.sh" "root:webops 750"
check "secrets/ is root 700" owner_group_mode "$L/secrets" "root:root 700"
check "secrets/db.env is root 600" owner_group_mode "$L/secrets/db.env" "root:root 600"

section "uploads & public"
check "uploads/ is 1777 (sticky bit set)" mode_is "$L/uploads" 1777
check "every directory under public/ is 755" all_modes "$L/public" d 755
check "every file under public/ is 644" all_modes "$L/public" f 644

section "ACL"
check "logs/app.log still root:root 640" owner_group_mode "$L/logs/app.log" "root:root 640"
check "ACL grants webdev read on logs/app.log" acl_has_webdev_read
check "webdev can actually read the log" webdev_can_read

section "Answers"
check_answer_is "octal for rwxr-x---" b04 octal "750"
check_answer_is "symbolic form of 0754" b04 symbolic "rwxr-xr--"

finish
