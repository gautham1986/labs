#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
for u in alice bob carol appsvc; do
  pkill -u "$u" 2>/dev/null
  userdel -r "$u" >/dev/null 2>&1 || userdel "$u" >/dev/null 2>&1
done
rm -rf /var/lib/appsvc /srv/devops /etc/sudoers.d/alice
for g in devops auditors alice bob carol appsvc; do groupdel "$g" >/dev/null 2>&1; done
exit 0
