# a04 · Solution

```bash
# 1. service limit via drop-in
cat /run/lab-a04/status
sudo mkdir -p /etc/systemd/system/lab-a04-api.service.d
printf '[Service]\nLimitNOFILE=8192\n' | sudo tee /etc/systemd/system/lab-a04-api.service.d/limits.conf
sudo systemctl daemon-reload
sudo systemctl restart lab-a04-api
systemctl show -p LimitNOFILE lab-a04-api
sleep 4; cat /run/lab-a04/status

# 2. per-user limits (applied by pam_limits at login)
sudo tee /etc/security/limits.d/batch.conf > /dev/null <<'LIM'
batch  soft  nofile  4096
batch  hard  nofile  8192
batch  -     nproc   2048
LIM
sudo su - batch -s /bin/bash -c 'ulimit -Sn; ulimit -Hn; ulimit -u'

# 3. kernel parameters
sudo tee /etc/sysctl.d/90-lab.conf > /dev/null <<'SYS'
net.core.somaxconn = 8192
net.ipv4.tcp_fin_timeout = 15
net.ipv4.ip_local_port_range = 10240 65000
vm.swappiness = 10
SYS
sudo sysctl -p /etc/sysctl.d/90-lab.conf
```

## Why

- systemd services don't go through PAM login, so `limits.conf` doesn't apply to them; use
  `LimitNOFILE=` (and friends) in the unit. A drop-in survives package upgrades of the unit.
- Soft limit = what the process gets; hard limit = the ceiling it may raise itself to.
- `sysctl -w` is lost on reboot; files in `/etc/sysctl.d/` are applied at boot by
  `systemd-sysctl.service`. Always do both: apply now, persist in a file.
