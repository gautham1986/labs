# i05 · Solution

```bash
# 1 + 2: listeners with process names (root to see everything)
sudo ss -tlnp
sudo ss -Htlnp | awk '/"mystery-svc"/ {n = split($4, a, ":"); print a[n]}' > ~/answers/i05-port.txt
sudo ss -Htlnp 'sport = :8443' | grep -o 'users:(("[^"]*' | cut -d'"' -f2 | head -1 > ~/answers/i05-proc.txt

# 3 + 4: default route, its interface and address
ip route show default
ip route show default | awk '{print $3; exit}' > ~/answers/i05-gw.txt
IFACE=$(ip route show default | awk '{print $5; exit}')
ip -4 -o addr show dev "$IFACE" | awk '{print $4}' | cut -d/ -f1 | head -1 > ~/answers/i05-ip.txt

# 5: resolver config
awk '$1 == "nameserver" {print $2; exit}' /etc/resolv.conf > ~/answers/i05-dns.txt

# 6: static host entries
echo '10.10.0.15  db.lab.internal' | sudo tee -a /etc/hosts
echo '10.10.0.16  cache.lab.internal' | sudo tee -a /etc/hosts
getent hosts db.lab.internal cache.lab.internal
```

## Why

- `ss -tlnp` answers "what is listening and who owns it" - the first thing to check when a port
  conflict or unexpected service shows up.
- `-n` skips DNS/service-name lookups: faster, and shows real port numbers.
- Name resolution goes through NSS (`/etc/nsswitch.conf`): usually `files` (/etc/hosts) first, then
  `dns`. `dig`/`nslookup` talk to DNS directly and ignore /etc/hosts; `getent` follows NSS like
  applications do.
