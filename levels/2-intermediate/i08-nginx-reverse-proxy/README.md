# i08 · nginx as a reverse proxy

**Level:** Intermediate · **Time:** ~40 min · **Needs:** systemd, nginx

## Scenario

The `backend` app runs on `127.0.0.1:5000` (unit `i08-backend.service`) - it is deliberately
not exposed. Put nginx in front of it on port **80**: proxy API traffic, serve static files
directly with caching, compress text, answer load-balancer health checks itself, and log to
its own file.

Static files live in `/opt/lab/i08/static/` (`logo.txt`, `style.css`).

## Tasks

1. Create `/etc/nginx/sites-available/i08.conf`, enable it with a symlink in `sites-enabled/`,
   and **disable the default site**.
2. `server` listens on port **80** as the default server.
3. `location /` proxies to `http://127.0.0.1:5000` and passes the headers `Host`, `X-Real-IP`,
   `X-Forwarded-For` and `X-Forwarded-Proto`.
4. `location /static/` serves files from `/opt/lab/i08/static/` with a cache lifetime of
   **7 days** (`Cache-Control: max-age=604800`).
5. `location = /healthz` returns **200** with body `ok` straight from nginx (no proxying).
6. **gzip** is enabled for CSS (and other text types).
7. Requests are logged to `/var/log/nginx/i08.access.log`.
8. nginx is **enabled** and **running**, and `nginx -t` passes.

From your host browser (Docker env): http://localhost:8080 maps to port 80 in the box.

> If `nginx -t` complains `socket() [::]:80 failed (97: Address family not supported)`, IPv6 is
> disabled in this container. Don't use `listen [::]:80` here (the stock default site does).

## Commands to learn

`nginx -t` `nginx -T` `systemctl reload nginx` `curl -i` `curl -I` `curl -H 'Accept-Encoding: gzip' -I`
`tail -f /var/log/nginx/*.log` `ln -s` `ss -tlnp`
Docs: `proxy_pass`, `proxy_set_header`, `alias` vs `root`, `expires`, `gzip_types`, `return`, `access_log`

## Done when

`lab check i08` passes.

## Explore (not graded)

- `alias` vs `root` in `location /static/`: try both. Which path does nginx look for in each case?
  (`error.log` tells you.)
- Stop the backend (`systemctl stop i08-backend`) and `curl -i localhost/`. 502 vs 504 - what's
  the difference? Add a custom error page.
- Add an `upstream` block with two backends and watch round-robin.
- Add a rate limit (`limit_req_zone`) to `/` and hammer it with `for i in $(seq 50); do curl ...`.
