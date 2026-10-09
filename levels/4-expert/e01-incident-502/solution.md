# e01 · Solution

Root causes:
1. The cache volume `/var/lib/shop/cache` (1 MB tmpfs) was full of a stale `stale-sessions.bin`,
   so `shop` crashed at startup writing `warmup.json` (ENOSPC) and restart-looped -> 502.
2. nginx's upstream pointed at `127.0.0.1:5005`; shop listens on `5050` -> still 502 once shop was up.
3. `proxy_read_timeout 1s` is shorter than `/products`' normal ~2 s response -> 504 on that path.

```bash
# triage: follow the request
curl -s -o /dev/null -w '%{http_code}\n' localhost:8088/ || true
sudo tail -n 5 /var/log/nginx/error.log
sudo ss -tlnp | grep -E '5005|5050' || echo "nothing listening upstream"
systemctl status shop --no-pager | head -5 || true
journalctl -u shop -n 5 --no-pager -o cat || true
df -h /var/lib/shop/cache

# fix 1: free the cache volume, restart the app
sudo rm -f /var/lib/shop/cache/stale-sessions.bin
sudo systemctl reset-failed shop
sudo systemctl restart shop
sleep 2; curl -s localhost:5050/health

# fix 2 + 3: upstream port and timeout
grep -nE 'server 127|proxy_read_timeout' /etc/nginx/sites-available/shop.conf
sudo sed -i -e 's/127.0.0.1:5005/127.0.0.1:5050/' \
            -e 's/proxy_read_timeout 1s;/proxy_read_timeout 10s;/' /etc/nginx/sites-available/shop.conf
sudo nginx -t && sudo systemctl reload nginx
sleep 1

curl -s -o /dev/null -w '/ %{http_code}\n' localhost:8088/
curl -s -o /dev/null -w '/products %{http_code} %{time_total}s\n' localhost:8088/products

cp /lab/templates/postmortem.md ~/answers/e01-postmortem.md
cat >> ~/answers/e01-postmortem.md <<'PM'

<!-- filled in for the reference solution -->
## Summary
shop.example.com returned 502 for all users for ~25 minutes because the shop app was crash-looping
on a full cache volume, and nginx was also pointed at the wrong upstream port. After both were fixed,
/products returned 504 because nginx's read timeout (1s) was shorter than its normal latency (2s).

## Impact
100% of requests failed for ~25 min; /products failed for a further ~10 min. No data loss.

## Timeline
03:12 alert fires (5xx > 50%). 03:15 nginx error log shows connection refused to 127.0.0.1:5005.
03:18 shop.service found in a restart loop: ENOSPC writing warmup.json. 03:21 stale cache file removed,
shop running on 5050. 03:24 upstream port corrected, / returns 200. 03:30 /products 504 -> timeout raised to 10s.

## Root cause
Cache volume had no cleanup or size alerting; an untested config change left a typo in the upstream
port and a too-aggressive proxy_read_timeout.

## Resolution
Removed stale cache data, fixed upstream port, raised proxy_read_timeout to 10s, reloaded nginx.

## Action items
- Add a cache TTL/cleanup job (owner: app team).
- Alert on cache volume usage > 80% and on 5xx rate at the proxy (owner: SRE).
- Validate nginx config changes in CI with an end-to-end smoke test (owner: platform).
- Set timeouts from measured p99 latency, documented next to the config.
PM
wc -w ~/answers/e01-postmortem.md
```
