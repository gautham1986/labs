# e06 · Zero-downtime blue/green deploys

**Level:** Expert · **Time:** ~75 min · **Needs:** systemd, nginx

## Scenario

Deploys currently mean `systemctl restart app` and ~3 seconds of errors while it warms up.
Users notice. Build a **blue/green** deploy script: start the new release next to the old one,
switch traffic only when it's healthy, and refuse to ship a broken release.

```
                     ┌─> app@blue   127.0.0.1:7001  (systemd template unit app@.service)
client -> nginx :8086┤
                     └─> app@green  127.0.0.1:7002
upstream target: /etc/nginx/e06-upstream.conf   (one line: server 127.0.0.1:700X;)
```

- Each color's config is `/etc/e06/<color>.env` with `PORT=` and `RELEASE=`.
- Releases live in `/opt/lab/e06/releases/` (`v1`, `v2`, `v3-broken`). They take a few
  seconds to start answering.
- `GET /version` returns the release name; `GET /health` returns 200 when healthy.
- Right now **blue** runs **v1** and gets all traffic; green is stopped.

## Tasks

Write `/opt/lab/e06/deploy.sh <release>` (bash, executable) that:

1. finds the **active** color (from the upstream file) and picks the **other** one;
2. points the idle color at `<release>` (edit its `.env`) and (re)starts `app@<idle>`;
3. waits until `http://127.0.0.1:<idle-port>/health` returns 200, up to **30 s**;
   if it never does: stops the idle color, leaves traffic alone, and **exits non-zero**;
4. switches nginx to the idle port **atomically** (`nginx -t` before `reload`);
5. verifies through nginx that `/version` now returns `<release>`;
6. stops the old color, and exits 0.

Try it: `sudo /opt/lab/e06/deploy.sh v2` while another terminal runs
`while true; do curl -s -o /dev/null -w '%{http_code} ' localhost:8086/version; sleep 0.1; done`

## Commands to learn

`systemctl start/stop/restart app@green` `systemctl is-active` (template units: `%i`)
`curl -fsS -m 2` `until ...; do sleep 0.5; done` `timeout` `mktemp` + `mv` `nginx -t` `systemctl reload nginx`
`trap ... ERR` `set -euo pipefail`

## Done when

`lab check e06` passes. The checker runs your script under constant traffic (every ~50 ms):
**one** non-200 response fails the deploy. It deploys forward, back, and then tries
`v3-broken`, which must be rejected with zero user impact.

## Explore (not graded)

- Why does `systemctl reload nginx` not drop in-flight requests, but `restart` does?
- Add a **canary** step: send 10% of traffic to the new color (`weight=` in the upstream) for a
  minute and watch its error rate before going 100%.
- Database migrations make blue/green hard. Look up "expand/contract" (parallel change).
- How do Kubernetes `readinessProbe` and rolling updates (`maxUnavailable: 0`) implement the same idea?
