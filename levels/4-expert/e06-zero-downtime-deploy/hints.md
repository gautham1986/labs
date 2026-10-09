Active color: `grep -q ':7001' /etc/nginx/e06-upstream.conf && active=blue || active=green`.
Then `idle` is the other one, and `port` comes from `/etc/e06/$idle.env` (`source` it).
---
Update the idle env file: `sed -i "s/^RELEASE=.*/RELEASE=$release/" /etc/e06/$idle.env`
Check the release exists first (`[[ -d /opt/lab/e06/releases/$release ]]`).
---
Health wait loop with a deadline:
```
deadline=$((SECONDS + 30))
until curl -fsS -m 2 -o /dev/null "http://127.0.0.1:$port/health"; do
  (( SECONDS >= deadline )) && { systemctl stop "app@$idle"; echo "unhealthy" >&2; exit 1; }
  sleep 0.5
done
```
---
Atomic switch: write the new upstream line to a temp file next to the real one, `mv` it into
place, then `nginx -t && systemctl reload nginx`. If `nginx -t` fails, put the old file back.
---
After reload, give nginx a moment and verify with `curl -fsS localhost:8086/version`. Only then
`systemctl stop app@$active`.
