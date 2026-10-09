#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
F=$LAB_ANSWERS/e05-findings.md

only_root_uid0() { [[ "$(awk -F: '$3 == 0 {print $1}' /etc/passwd)" == root ]]; }
no_empty_pw() { [[ -z "$(awk -F: '$2 == ""' /etc/shadow)" ]]; }
no_svc_sudo() { ! grep -rqs 'svc-backup' /etc/sudoers /etc/sudoers.d/; }
no_odd_suid() { [[ -z "$(find /usr/local /opt /tmp /home /var/tmp -xdev -type f -perm /6000 2>/dev/null)" ]]; }
shadow_ok() { [[ "$(stat -c %a /etc/shadow)" =~ ^(640|600|400|0)$ && "$(stat -c %U /etc/shadow)" == root ]]; }
cron_script_safe() {
  [[ ! -f /etc/cron.d/e05-maintenance ]] && return 0
  local m; m=$(stat -c %a /opt/lab/e05/maintenance.sh 2>/dev/null) || return 0
  [[ "$(stat -c %U /opt/lab/e05/maintenance.sh)" == root ]] && (( (8#$m & 8#022) == 0 ))
}
sshd_val() { sshd -T 2>/dev/null | grep -qix "$1"; }
key_gone() { ! grep -qs "$(awk '{print $2}' "$LAB_VAR/e05/planted_key.pub")" /root/.ssh/authorized_keys; }
no_31337() { port_closed 31337; }
netsvcd_gone() { ! systemctl is-enabled --quiet netsvcd 2>/dev/null && [[ ! -e /usr/local/sbin/netsvcd ]]; }
learner_sudo() { sudo -l -U "$LAB_USER" 2>/dev/null | grep -Eq '\(ALL( : ALL)?\) (NOPASSWD: )?ALL'; }
findings() { [[ $(grep -Ec '^[[:space:]]*([-*]|[0-9]+\.)[[:space:]]+[^[:space:]]' "$F") -ge 9 ]]; }

section "Accounts & privileges"
check "only root has UID 0" only_root_uid0
check "no account has an empty password" no_empty_pw
check "no sudo rights for svc-backup" no_svc_sudo
check "no SUID/SGID files in /usr/local, /opt, /home, /tmp" no_odd_suid

section "Files & scheduled jobs"
check "/etc/shadow is not world-readable (root-owned, 640/600)" shadow_ok
check "scripts run by root from cron aren't writable by others" cron_script_safe

section "Remote access"
check "sshd: permitrootlogin no" sshd_val 'permitrootlogin no'
check "sshd: passwordauthentication no" sshd_val 'passwordauthentication no'
check "planted key removed from /root/.ssh/authorized_keys" key_gone

section "Network"
check "nothing listens on port 31337" no_31337
check "netsvcd service disabled and binary removed" netsvcd_gone

section "Didn't break anything"
check "visudo -c passes" visudo -c
check "$LAB_USER still has sudo" learner_sudo
check "sshd is running" service_active ssh
check "cron is running" service_active cron

section "Report"
check "e05-findings.md lists at least 9 findings (one bullet each)" findings

finish
