Get the PID: `systemctl show -p MainPID --value report-svc`. Then
`sudo strace -f -p <PID> -e trace=openat`. It retries every 2 seconds, so wait for a round.
`ENOENT` = "No such file or directory".
---
The ops notes say the flags file is JSON. Create the directory and the file:
`sudo mkdir -p <dir>` and write `{"reports_enabled": true}` into it.
---
Now trace network syscalls: `sudo strace -f -p <PID> -e trace=connect`. Look at `sin_port=htons(...)`
and the result (`ECONNREFUSED`).
---
`/opt/lab/a06/bin/minicache --help` shows it takes `--port`. A unit like:
```
[Service]
ExecStart=/opt/lab/a06/bin/minicache --port <PORT>
Restart=on-failure
DynamicUser=yes
[Install]
WantedBy=multi-user.target
```
