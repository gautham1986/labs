# i06 · Solution

```bash
# 1. key pair
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -C "$(whoami)@lab"

# 2. authorize it for deploy (no password, so do what ssh-copy-id would do, with sudo)
sudo install -d -m 700 -o deploy -g deploy /home/deploy/.ssh
sudo tee -a /home/deploy/.ssh/authorized_keys < ~/.ssh/id_ed25519.pub > /dev/null
sudo chown deploy:deploy /home/deploy/.ssh/authorized_keys
sudo chmod 600 /home/deploy/.ssh/authorized_keys

# 3. client alias
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat >> ~/.ssh/config <<'CFG'

Host app
    HostName localhost
    User deploy
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
CFG
chmod 600 ~/.ssh/config
ssh -o StrictHostKeyChecking=accept-new app 'whoami; hostname'

# 4. harden sshd: validate, then reload
sudo tee /etc/ssh/sshd_config.d/10-hardening.conf > /dev/null <<'CFG'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
MaxAuthTries 3
CFG
sudo sshd -t && sudo systemctl reload ssh
sudo sshd -T | grep -Ei '^(permitrootlogin|passwordauthentication|maxauthtries) '

# 5. copy over SSH
scp /opt/lab/i06/release.tar.gz app:
ssh app 'ls -l release.tar.gz && sha256sum release.tar.gz'
```

## Why

- sshd refuses keys if `~/.ssh` or `authorized_keys` are group/world-writable (`StrictModes`).
  "Permission denied (publickey)" + wrong modes is the #1 SSH support ticket.
- Drop-ins in `sshd_config.d/` keep your changes separate from the distro file and are easy to
  ship with config management.
- `sshd -t` before reload: a syntax error plus a restart = locked out of a remote box.
- ed25519 keys are short, fast and secure; prefer them over RSA for new keys.
