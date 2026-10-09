#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
UH=$(user_home)
DH=$(user_home deploy)

key_is_ed25519() { ssh-keygen -l -f "$UH/.ssh/id_ed25519.pub" | grep -q '(ED25519)'; }
perms_ok() {
  [[ "$(stat -c '%a %U' "$DH/.ssh")" == "700 deploy" && "$(stat -c '%a %U' "$DH/.ssh/authorized_keys")" == "600 deploy" ]]
}
key_authorized() { grep -qF "$(awk '{print $2}' "$UH/.ssh/id_ed25519.pub")" "$DH/.ssh/authorized_keys"; }
alias_resolves() {
  local g; g=$(su - "$LAB_USER" -c 'ssh -G app')
  grep -qx 'user deploy' <<< "$g" && grep -Eqx 'hostname (localhost|127\.0\.0\.1|::1)' <<< "$g"
}
ssh_as_learner() { su - "$LAB_USER" -c 'ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 app whoami' | grep -qx deploy; }
sshd_effective() { sshd -T 2>/dev/null | grep -qix "$1"; }
dropin_exists() { grep -lEiq '^\s*PasswordAuthentication\s+no' /etc/ssh/sshd_config.d/*.conf 2>/dev/null; }
password_refused() {  # the server must not offer "password" as an auth method
  local methods
  methods=$(ssh -v -o BatchMode=yes -o PubkeyAuthentication=no -o StrictHostKeyChecking=no \
              -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 deploy@localhost true 2>&1 |
            tr -d '\r' | grep 'Authentications that can continue' | tail -1)
  [[ -n "$methods" && "$methods" != *password* ]]
}
copied() { [[ -f "$DH/release.tar.gz" ]] && cmp -s "$DH/release.tar.gz" /opt/lab/i06/release.tar.gz && [[ "$(stat -c %U "$DH/release.tar.gz")" == deploy ]]; }

section "Keys"
check "~/.ssh/id_ed25519 exists and is an ed25519 key" key_is_ed25519
check "your public key is in deploy's authorized_keys" key_authorized
check "deploy's ~/.ssh is 700 and authorized_keys is 600 (owned by deploy)" perms_ok

section "Client config"
check "'ssh app' resolves to deploy@localhost" alias_resolves
check "'ssh app' logs in with your key (non-interactive)" ssh_as_learner

section "sshd hardening"
check "hardening is in a drop-in under /etc/ssh/sshd_config.d/" dropin_exists
check "sshd config is valid (sshd -t)" sshd -t
check "effective: permitrootlogin no" sshd_effective 'permitrootlogin no'
check "effective: passwordauthentication no" sshd_effective 'passwordauthentication no'
check "effective: maxauthtries 3" sshd_effective 'maxauthtries 3'
check "running sshd refuses password logins (reloaded)" password_refused
check "sshd is active" service_active ssh

section "Transfer"
check "release.tar.gz copied to deploy's home, owned by deploy, intact" copied

finish
