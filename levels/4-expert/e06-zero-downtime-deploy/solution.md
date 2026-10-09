# e06 · Solution

```bash
sudo tee /opt/lab/e06/deploy.sh > /dev/null <<'SCRIPT'
#!/usr/bin/env bash
# deploy.sh <release> - blue/green deploy behind nginx with health gating and safe failure
set -euo pipefail

release=${1:?usage: deploy.sh <release>}
UPSTREAM=/etc/nginx/e06-upstream.conf
RELEASES=/opt/lab/e06/releases
log() { printf '[deploy %s] %s\n' "$(date +%T)" "$*" >&2; }

[[ -d "$RELEASES/$release" ]] || { log "no such release: $release"; exit 2; }

if grep -q ':7001;' "$UPSTREAM"; then active=blue idle=green; else active=green idle=blue; fi
port=$(grep -oP '^PORT=\K[0-9]+' "/etc/e06/$idle.env")
log "active=$active idle=$idle (port $port) -> deploying $release to $idle"

sed -i "s/^RELEASE=.*/RELEASE=$release/" "/etc/e06/$idle.env"
systemctl restart "app@$idle"

deadline=$((SECONDS + 30))
until curl -fsS -m 2 -o /dev/null "http://127.0.0.1:$port/health"; do
  if (( SECONDS >= deadline )) || ! systemctl is-active --quiet "app@$idle"; then
    log "$release on $idle never became healthy - aborting, traffic stays on $active"
    systemctl stop "app@$idle"
    exit 1
  fi
  sleep 0.5
done
log "$idle is healthy"

backup=$(mktemp); cp "$UPSTREAM" "$backup"
tmp=$(mktemp "$UPSTREAM.XXXXXX")
echo "server 127.0.0.1:$port;" > "$tmp"
chmod 644 "$tmp"
mv "$tmp" "$UPSTREAM"
if ! nginx -t 2>/dev/null; then
  log "nginx config invalid - restoring"; cp "$backup" "$UPSTREAM"; systemctl stop "app@$idle"; exit 1
fi
systemctl reload nginx

for _ in $(seq 1 20); do
  [[ "$(curl -fsS -m 2 http://127.0.0.1:8086/version)" == "$release" ]] && break
  sleep 0.25
done
[[ "$(curl -fsS -m 2 http://127.0.0.1:8086/version)" == "$release" ]] || { log "verification failed"; exit 1; }

sleep 1   # let in-flight requests on the old color finish
systemctl stop "app@$active"
log "done: $release live on $idle; $active stopped"
SCRIPT
sudo chmod 755 /opt/lab/e06/deploy.sh

sudo /opt/lab/e06/deploy.sh v2
curl -s localhost:8086/version
sudo /opt/lab/e06/deploy.sh v3-broken || echo "rejected as expected"
curl -s localhost:8086/version
```

## Why

- Health-gated switching means users never hit a cold process; the old version keeps serving
  until the new one is proven.
- nginx `reload` starts new workers with the new config and lets old workers finish their
  requests - no dropped connections.
- Failing closed (abort, keep old traffic) is the most important property of a deploy script.
