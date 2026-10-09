`systemctl status lab-a04-api` and `cat /run/lab-a04/status`. Compare the "soft limit" it
reports with `cat /proc/<MainPID>/limits`.
---
`sudo systemctl edit lab-a04-api` opens an editor for a drop-in
(`/etc/systemd/system/lab-a04-api.service.d/override.conf`). Add:
```
[Service]
LimitNOFILE=8192
```
Then `sudo systemctl restart lab-a04-api`. (Non-interactive: create the file yourself and
`daemon-reload`.)
---
limits.d format: `<domain> <type> <item> <value>`, e.g. `batch soft nofile 4096`.
Types: `soft`, `hard` (or `-` for both). Items: `nofile`, `nproc`, ...
Test with `sudo su - batch -s /bin/bash -c 'ulimit -Sn; ulimit -Hn; ulimit -u'`.
---
sysctl.d format: `key = value`, one per line. Apply all files with `sudo sysctl --system`
(or just yours with `sudo sysctl -p /etc/sysctl.d/90-lab.conf`).
