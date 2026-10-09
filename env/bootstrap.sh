#!/usr/bin/env bash
# Provision an Ubuntu 22.04/24.04 (or Debian 12) VM as a practice box.
#
# Used by env/Vagrantfile and env/cloud-init.yaml, or run by hand on any fresh VM:
#   sudo ./env/bootstrap.sh [/path/to/repo]
#
# Never run this on a machine you care about: the labs deliberately break things.
set -euo pipefail

REPO="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LAB_USER="${LAB_USER:-${SUDO_USER:-learner}}"

[[ $EUID -eq 0 ]] || { echo "run as root: sudo $0" >&2; exit 1; }
[[ -f "$REPO/lab" ]] || { echo "can't find the lab repo at $REPO" >&2; exit 1; }

echo "==> Installing packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
grep -vE '^\s*(#|$)' "$REPO/env/packages.txt" \
  | xargs apt-get install -y -q --no-install-recommends
systemctl disable --now nginx prometheus-node-exporter >/dev/null 2>&1 || true
systemctl enable --now ssh cron >/dev/null 2>&1 || true

echo "==> Creating user '$LAB_USER'"
if ! id "$LAB_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$LAB_USER"
  echo "$LAB_USER:$LAB_USER" | chpasswd
fi
for g in sudo adm systemd-journal; do usermod -aG "$g" "$LAB_USER" 2>/dev/null || true; done
echo "$LAB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-lab
chmod 0440 /etc/sudoers.d/90-lab

echo "==> Wiring up the lab command"
if [[ "$REPO" != /lab ]]; then
  if [[ -e /lab && ! -L /lab ]]; then
    echo "   /lab exists and is not a symlink - leaving it alone"
  else
    ln -sfn "$REPO" /lab
  fi
fi
ln -sfn /lab/lab /usr/local/bin/lab
install -m 0644 "$REPO/env/profile-lab.sh" /etc/profile.d/zz-lab.sh

echo
echo "Done. Log in as '$LAB_USER' and run:  lab list"
