#!/usr/bin/env bash
# i06 setup: a deploy account with an unknown password, sshd running, a release to ship
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd sshd ssh scp
prepare_answers
bash "$LAB_DIR/cleanup.sh"

id deploy >/dev/null 2>&1 || useradd -m -s /bin/bash deploy
echo "deploy:$(head -c 24 /dev/urandom | base64)" | chpasswd
mkdir -p /run/sshd
systemctl enable --now ssh >/dev/null 2>&1 || systemctl enable --now sshd >/dev/null 2>&1

mkdir -p /opt/lab/i06/payload
echo "release $(date +%s)" > /opt/lab/i06/payload/VERSION
head -c 200000 /dev/urandom > /opt/lab/i06/payload/app.bin
tar -czf /opt/lab/i06/release.tar.gz -C /opt/lab/i06 payload
chmod 644 /opt/lab/i06/release.tar.gz
