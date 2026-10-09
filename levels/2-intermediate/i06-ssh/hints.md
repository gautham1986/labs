`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''` (empty passphrase via `-N ''`).
---
`ssh-copy-id` needs the password, which you don't have. Do it by hand with sudo:
```
sudo install -d -m 700 -o deploy -g deploy ~deploy/.ssh
cat ~/.ssh/id_ed25519.pub | sudo tee -a ~deploy/.ssh/authorized_keys
sudo chown deploy:deploy ~deploy/.ssh/authorized_keys
sudo chmod 600 ~deploy/.ssh/authorized_keys
```
---
`~/.ssh/config`:
```
Host app
    HostName localhost
    User deploy
    IdentityFile ~/.ssh/id_ed25519
```
`ssh -G app | grep -E '^(user|hostname) '` shows what ssh will actually use.
---
sshd reads `/etc/ssh/sshd_config.d/*.conf` - *first* value wins for most options, so a
low-numbered file overrides later ones. `sudo sshd -t` validates, `sudo sshd -T | grep -i passwordauth`
shows the effective value. Then `sudo systemctl reload ssh`.
---
`scp /opt/lab/i06/release.tar.gz app:` (the trailing colon means "remote home directory").
