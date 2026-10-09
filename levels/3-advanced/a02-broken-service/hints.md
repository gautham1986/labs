Start with `systemctl status payments` - the `Main PID ... status=XXX/NAME` part tells you
*which stage* failed. Then `journalctl -u payments -n 30 --no-pager` for details.
---
`status=217/USER` means systemd couldn't switch to the configured user. Compare `User=` in the
unit with `getent passwd | grep pay`. After editing the unit: `sudo systemctl daemon-reload`.
---
`status=203/EXEC` means the binary in `ExecStart=` doesn't exist or isn't executable.
`ls -l /usr/bin/python*` - which Python is actually installed?
---
"cannot read config ... Permission denied": who owns it, what mode? Give the *group* read access
instead of everyone: `chown root:payments` + `chmod 640`.
---
"cannot listen ... Address already in use": `sudo ss -tlnp 'sport = :8090'` shows who's squatting
on the port. Is it something that should be running?
---
If systemd refuses to start it at all ("start request repeated too quickly"):
`sudo systemctl reset-failed payments` and start again.
