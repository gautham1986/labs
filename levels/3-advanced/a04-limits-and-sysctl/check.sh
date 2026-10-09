#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
U=lab-a04-api.service

dropin_has_limit() { grep -Eqs '^\s*LimitNOFILE\s*=\s*8192' /etc/systemd/system/$U.d/*.conf; }
unit_untouched() { ! grep -q LimitNOFILE /etc/systemd/system/$U; }
effective_limit() { [[ "$(systemctl show -p LimitNOFILE --value $U)" -ge 8192 ]]; }
api_ok() {
  wait_for 8 bash -c '[[ $(( $(date +%s) - $(stat -c %Y /run/lab-a04/status) )) -lt 8 ]] && grep -q "^OK" /run/lab-a04/status'
}
batch_limits() {
  [[ "$(su - batch -s /bin/bash -c 'echo "$(ulimit -Sn) $(ulimit -Hn) $(ulimit -Su) $(ulimit -Hu)"')" == "4096 8192 2048 2048" ]]
}
sysctl_file() { grep -Eq "^\s*$1\s*=\s*$2\s*$" /etc/sysctl.d/90-lab.conf; }
sysctl_live() {
  local f; f=/proc/sys/${1//.//}
  [[ "$(sysctl -n "$1" | tr -s '\t ' ' ')" == "$2" ]]
}

section "Service limits"
check "drop-in in $U.d/ sets LimitNOFILE=8192" dropin_has_limit
check "the unit file itself was not edited" unit_untouched
check "effective LimitNOFILE >= 8192" effective_limit
check "API reports OK (holds 3000 files)" api_ok

section "User limits (batch)"
check "batch gets nofile 4096/8192 and nproc 2048/2048 at login" batch_limits

section "Kernel parameters"
check "90-lab.conf: net.core.somaxconn = 8192" sysctl_file 'net\.core\.somaxconn' 8192
check "90-lab.conf: net.ipv4.tcp_fin_timeout = 15" sysctl_file 'net\.ipv4\.tcp_fin_timeout' 15
check "90-lab.conf: net.ipv4.ip_local_port_range = 10240 65000" sysctl_file 'net\.ipv4\.ip_local_port_range' '10240[[:space:]]+65000'
check "90-lab.conf: vm.swappiness = 10" sysctl_file 'vm\.swappiness' 10
check "applied: net.core.somaxconn" sysctl_live net.core.somaxconn 8192
check "applied: net.ipv4.tcp_fin_timeout" sysctl_live net.ipv4.tcp_fin_timeout 15
check "applied: net.ipv4.ip_local_port_range" sysctl_live net.ipv4.ip_local_port_range '10240 65000'
if [[ -w /proc/sys/vm/swappiness ]]; then
  check "applied: vm.swappiness" sysctl_live vm.swappiness 10
else
  warn "vm.swappiness is read-only here (unprivileged container) - file check only"
fi

finish
