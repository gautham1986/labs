# i01 · Running an app as a systemd service

**Level:** Intermediate · **Time:** ~30 min · **Needs:** systemd

## Scenario

A developer handed you an app and said "I just run it with `python3 inventory.py` in tmux".
That's not production. Turn it into a proper service: own user, starts on boot, restarts when
it crashes, logs to the journal.

The app is at `/opt/lab/i01/inventory.py`. It listens on the port in the `PORT` environment
variable and answers `GET /health`.

## Tasks

1. Create a **system user** `inventory` with no login shell to run the app.
2. Write a unit file `/etc/systemd/system/inventory.service` that:
   - runs `/usr/bin/python3 /opt/lab/i01/inventory.py --name inventory`
   - runs as user `inventory`
   - sets `PORT=8081` (via `Environment=` or an `EnvironmentFile=` such as `/etc/default/inventory`)
   - restarts automatically **on failure**, waiting 2 seconds between restarts
   - starts after the network is up and is wanted by `multi-user.target`
3. Load it, **enable** it (start on boot) and **start** it.
4. Verify: `curl -s localhost:8081/health` and `journalctl -u inventory`.

The checker will `kill -9` your service to make sure systemd brings it back.

## Commands to learn

`systemctl daemon-reload | start | stop | restart | status | enable --now | is-active | cat | show -p`
`systemctl list-units --type=service` `systemctl list-unit-files` `journalctl -u UNIT -f -n 50`
`systemd-analyze verify UNIT` `man systemd.service` `man systemd.exec` `man systemd.unit`

## Done when

`lab check i01` passes.

## Explore (not graded)

- `systemctl cat ssh.service` - read a real-world unit. What does `ExecReload=` do?
- Add hardening: `NoNewPrivileges=yes`, `ProtectSystem=strict`, `PrivateTmp=yes`,
  `ProtectHome=yes`. Then run `systemd-analyze security inventory` and compare the score.
- Use `systemctl edit inventory` to create a drop-in override instead of editing the unit.
  Where did it put the file?
- What's the difference between `Wants=`, `Requires=` and `After=`?
