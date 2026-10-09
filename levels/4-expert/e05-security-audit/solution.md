# e05 · Solution

Planted findings:

1. `toor` - a second account with **UID 0** (a root backdoor).
2. `svc-backup` - account with an **empty password**...
3. ...and a sudoers drop-in giving it **passwordless root** (`/etc/sudoers.d/99-svc`).
4. `/usr/local/bin/.sysutil` - hidden **SUID-root** copy of `find` (`find . -exec /bin/sh -p \;` = root shell).
5. `/etc/shadow` is **world-readable** (offline hash cracking).
6. `/opt/lab/e05/maintenance.sh` is **world-writable** and **run by root** from `/etc/cron.d/e05-maintenance`.
7. `/etc/ssh/sshd_config.d/00-legacy.conf` enables **root login** and **password auth**.
8. An unknown key (`deploy@ci-old`) in **/root/.ssh/authorized_keys**.
9. `netsvcd.service` - a **listener on 0.0.0.0:31337** (a copy of netcat), enabled at boot.

```bash
# --- audit (read-only) ---
awk -F: '$3 == 0 {print "uid0:", $1}' /etc/passwd
sudo awk -F: '$2 == "" {print "empty password:", $1}' /etc/shadow
sudo grep -rH . /etc/sudoers.d/
sudo find / -xdev -perm /6000 -type f 2>/dev/null | grep -Ev '^/usr/(bin|sbin|lib)/' || true
ls -l /etc/shadow /etc/passwd
cat /etc/cron.d/*; ls -l /opt/lab/e05/
sudo sshd -T | grep -Ei '^(permitrootlogin|passwordauthentication) '
sudo cat /root/.ssh/authorized_keys
sudo ss -tulpn

# --- remediate ---
sudo userdel toor 2>/dev/null || sudo sed -i '/^toor:/d' /etc/passwd /etc/shadow
sudo rm -f /etc/sudoers.d/99-svc && sudo visudo -c
sudo passwd -l svc-backup && sudo usermod -s /usr/sbin/nologin svc-backup
sudo rm -f /usr/local/bin/.sysutil
sudo chown root:shadow /etc/shadow && sudo chmod 640 /etc/shadow
sudo chown root:root /opt/lab/e05/maintenance.sh && sudo chmod 755 /opt/lab/e05/maintenance.sh
sudo rm -f /etc/ssh/sshd_config.d/00-legacy.conf
printf 'PermitRootLogin no\nPasswordAuthentication no\n' | sudo tee /etc/ssh/sshd_config.d/10-hardening.conf
sudo sshd -t && sudo systemctl reload ssh
sudo sed -i '/deploy@ci-old/d' /root/.ssh/authorized_keys
sudo systemctl disable --now netsvcd.service
sudo rm -f /etc/systemd/system/netsvcd.service /usr/local/sbin/netsvcd && sudo systemctl daemon-reload

cat > ~/answers/e05-findings.md <<'MD'
# e05 findings
- toor had UID 0 (hidden root account) - deleted the account
- svc-backup had an empty password - locked it and set a nologin shell
- /etc/sudoers.d/99-svc gave svc-backup NOPASSWD ALL - removed, visudo -c passes
- /usr/local/bin/.sysutil was a hidden SUID-root copy of find (root shell for anyone) - deleted
- /etc/shadow was world-readable (offline cracking) - restored 640 root:shadow
- /opt/lab/e05/maintenance.sh was world-writable but run by root via cron - root:root 755
- sshd allowed root login and passwords via 00-legacy.conf - removed, added hardening drop-in
- unknown key deploy@ci-old in /root/.ssh/authorized_keys - removed (rotate & investigate)
- netsvcd.service listened on 0.0.0.0:31337 (netcat copy) - stopped, disabled, deleted
MD
```
