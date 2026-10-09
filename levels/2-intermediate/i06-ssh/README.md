# i06 · SSH: keys, client config & server hardening

**Level:** Intermediate · **Time:** ~35 min · **Needs:** systemd, openssh-server

## Scenario

There's a `deploy` account on this box (pretend it's a remote server - you'll SSH to
`localhost`). Passwords are being phased out: set up key-based access, give yourself a
convenient alias, harden the SSH daemon, and ship a release tarball over SSH.

## Tasks

1. Generate an **ed25519** key pair for yourself at `~/.ssh/id_ed25519` (a passphrase is good
   practice; for this lab you may leave it empty so the checker can use it).
2. Authorize your public key for **`deploy@localhost`**. The `deploy` user's `~/.ssh` must be mode
   `700` and `authorized_keys` mode `600`, both owned by `deploy`. (You know deploy's password?
   No. You have sudo, though.)
3. Add a host alias `app` to **your** `~/.ssh/config` so that `ssh app` connects to `localhost`
   as user `deploy` with your ed25519 key.
4. Harden `sshd` with a drop-in file in `/etc/ssh/sshd_config.d/` (e.g. `10-hardening.conf`):
   - `PermitRootLogin no`
   - `PasswordAuthentication no`
   - `MaxAuthTries 3`
   Validate the config **before** reloading (`sshd -t`), then reload sshd.
5. Copy `/opt/lab/i06/release.tar.gz` to deploy's home directory **over SSH** (`scp` or `rsync`
   using your `app` alias).

## Commands to learn

`ssh-keygen -t ed25519 -C "comment"` `ssh-copy-id` `ssh -v` `ssh -G host` `~/.ssh/config`
`ssh-agent` / `ssh-add` `scp` `rsync -avz -e ssh` `sshd -t` `sshd -T` `systemctl reload ssh`
`/etc/ssh/sshd_config.d/` `~/.ssh/known_hosts` `ssh-keyscan`

## Done when

`lab check i06` passes.

> ⚠️ On a real remote server, keep your current session open while changing sshd settings
> and test with a **second** connection - otherwise one typo locks you out.

## Explore (not graded)

- `ssh -v app true` - read the handshake: which keys were offered and accepted?
- Local port forward: `ssh -L 9000:localhost:80 app` then `curl localhost:9000`.
- `ProxyJump` in `~/.ssh/config` to reach private hosts through a bastion.
- `ssh-agent` + `ssh-add`: type a key's passphrase once per session.
- With `make fleet` running, set up keys to `node1` and `node2` and run `ssh node1 uptime`.
