`sudo ss -tlnp` lists TCP listeners with the owning process (you need root to see other users'
processes). Look for `mystery-svc` in the last column.
---
`sudo ss -tlnp 'sport = :8443'` filters by port. Or `sudo lsof -iTCP:8443 -sTCP:LISTEN`.
---
`ip route show default` -> `default via <GATEWAY> dev <IFACE> ...`
then `ip -4 -br addr show dev <IFACE>`.
---
DNS servers are listed in `/etc/resolv.conf` as `nameserver` lines.
---
Static names go in `/etc/hosts` (format: `IP  name [aliases...]`). Test with `getent hosts db.lab.internal`.
