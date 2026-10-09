Follow the request path. `tail /var/log/nginx/error.log` tells you what nginx tried to connect
to and what happened. Compare that with `sudo ss -tlnp` - is anything listening there?
---
`systemctl status shop` and `journalctl -u shop -n 30`. It's in a restart loop. Why can't it
write its cache file? `df -h /var/lib/shop/cache`
---
The cache volume is full of a stale file nobody cleans up. Removing stale cache is safe.
Then `systemctl reset-failed shop; systemctl restart shop`.
---
Now `/` works but `/products` gives **504** after 1 s. Look for timeouts in the nginx site config.
Raise it for that path (or globally, with a reasonable value - not 1 hour), `nginx -t`, reload.
---
Postmortem: `cp /lab/templates/postmortem.md ~/answers/e01-postmortem.md` and fill it in.
Timeline = what you saw and did, with times (`journalctl` has timestamps).
