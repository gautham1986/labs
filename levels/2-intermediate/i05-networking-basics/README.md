# i05 · Networking basics: interfaces, routes, ports, names

**Level:** Intermediate · **Time:** ~30 min · **Needs:** any Linux

## Scenario

You've just been given SSH access to an unfamiliar server. Before touching anything, map out
how it's connected: its address, gateway, DNS, and what's listening. Then add some internal
host names the app team needs.

## Tasks

1. A process called `mystery-svc` is listening on a TCP port. Which port? Write it to
   `~/answers/i05-port.txt`.
2. Which **process name** is listening on TCP port **8443**? Write it to `~/answers/i05-proc.txt`.
3. Write this host's **default gateway** IP to `~/answers/i05-gw.txt`.
4. Write the **IPv4 address** of the interface that the default route uses to
   `~/answers/i05-ip.txt` (address only, no `/24`).
5. Write the IP of the **first DNS nameserver** this host is configured to use to
   `~/answers/i05-dns.txt`.
6. Make these names resolve on this host (no DNS server needed):
   `db.lab.internal` -> `10.10.0.15` and `cache.lab.internal` -> `10.10.0.16`.

## Commands to learn

`ip -br addr` `ip addr show dev X` `ip route` `ip route get 1.1.1.1` `ip neigh` `ip link`
`ss -tulpn` (`-t` tcp, `-u` udp, `-l` listening, `-p` process, `-n` numeric) `ss -tan state established`
`/etc/hosts` `/etc/resolv.conf` `/etc/nsswitch.conf` `getent hosts NAME` `dig` `host` `nslookup`
`ping` `traceroute` / `mtr` `nc -zv HOST PORT` `curl -v`

## Done when

`lab check i05` passes.

## Explore (not graded)

- `dig db.lab.internal` fails but `getent hosts db.lab.internal` works. Why? (Read `/etc/nsswitch.conf`.)
- `ip route get 8.8.8.8` - which interface and source address would be used?
- `sudo tcpdump -ni any port 53` in one terminal, `dig example.com` in another.
- Old vs new: `ifconfig`/`netstat`/`route` (net-tools) vs `ip`/`ss` (iproute2). Know both for
  interviews; use the new ones.
