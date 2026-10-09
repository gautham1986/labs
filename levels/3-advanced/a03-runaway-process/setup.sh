#!/usr/bin/env bash
# a03 setup: a disguised CPU burner, a watchdog that respawns it, and cron persistence
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd crontab
prepare_answers
bash "$LAB_DIR/cleanup.sh"
systemctl enable --now cron >/dev/null 2>&1

D=/usr/local/lib/.cache
mkdir -p "$D"
clone_bin yes "$D/kworker-u8"
cat > "$D/dbus-helper" <<'W'
#!/bin/bash
while :; do
  if ! pgrep -x kworker-u8 >/dev/null; then
    /usr/local/lib/.cache/kworker-u8 > /dev/null 2>&1 &
  fi
  sleep 2
done
W
cat > "$D/.update.sh" <<'U'
#!/bin/bash
pgrep -x dbus-helper >/dev/null || setsid /usr/local/lib/.cache/dbus-helper >/dev/null 2>&1 < /dev/null &
U
chmod 755 "$D/dbus-helper" "$D/.update.sh"
echo '* * * * * root /usr/local/lib/.cache/.update.sh' > /etc/cron.d/sysstat-collect
chmod 644 /etc/cron.d/sysstat-collect
touch -d '45 days ago' /etc/cron.d/sysstat-collect "$D" "$D"/*

spawn dbus-helper "$D/dbus-helper"
sleep 1
info "Watch it: top (press q to quit)"
