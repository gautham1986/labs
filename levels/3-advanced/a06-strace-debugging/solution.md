# a06 · Solution

```bash
PID=$(systemctl show -p MainPID --value report-svc)

# 1. which file? (timeout: strace runs until interrupted; 5s covers 2 retry rounds)
sudo timeout 5 strace -f -p "$PID" -e trace=openat 2>&1 | grep -v -e '/usr/lib' -e '/proc' | head || true
echo /var/lib/report-svc/feature-flags.json > ~/answers/a06-file.txt
cat /opt/lab/a06/OPS-NOTES.txt
sudo mkdir -p /var/lib/report-svc
echo '{"reports_enabled": true}' | sudo tee /var/lib/report-svc/feature-flags.json

# 2. which port?
sudo timeout 5 strace -f -p "$PID" -e trace=connect 2>&1 | head -3 || true
echo 6380 > ~/answers/a06-port.txt

# 3. run the dependency as a service
sudo tee /etc/systemd/system/minicache.service > /dev/null <<'UNIT'
[Unit]
Description=minicache for report-svc
Before=report-svc.service

[Service]
ExecStart=/opt/lab/a06/bin/minicache --port 6380
DynamicUser=yes
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
sudo systemctl daemon-reload
sudo systemctl enable --now minicache

# 4. verify
sleep 3; cat /run/report-svc/status
```

## Why

- When logs don't say *what*, syscalls do: every file open and network connection goes through
  the kernel, and strace shows the exact arguments and error codes.
- Filter (`-e trace=`) or you drown: a Python program opens hundreds of library files at startup.
- strace slows the traced process a lot - fine for diagnosis, be careful on hot production paths.
  (eBPF tools like `opensnoop`/`tcpconnect` from bcc-tools are the low-overhead alternative.)
