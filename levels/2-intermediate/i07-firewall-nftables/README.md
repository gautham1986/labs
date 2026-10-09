# i07 · Host firewall with nftables

**Level:** Intermediate · **Time:** ~40 min · **Needs:** root, nftables (systemd for persistence)

## Scenario

This box runs a public web app on **8080**, a Prometheus exporter on **9100** that only the
internal monitoring network (`10.0.0.0/8`) may scrape, and a database on **5432** that should
never be reachable from outside. Right now everything is wide open. Write a default-deny
host firewall.

## Tasks

Create `/etc/nftables.conf` with a table `inet filter` and an `input` chain that:

1. has **policy drop** (default deny) for incoming traffic;
2. accepts packets for **established/related** connections and drops **invalid** ones;
3. accepts everything on the **loopback** interface;
4. accepts **ICMP** and **ICMPv6** (ping, path MTU discovery, IPv6 neighbour discovery need it);
5. accepts **SSH (22)** but **rate-limits new SSH connections** (e.g. 10 per minute);
6. accepts **80, 443 and 8080** from anywhere;
7. accepts **9100** only from **10.0.0.0/8**.
8. Leave `5432` blocked.

Then load it and make it **persistent** (enable the `nftables` service).

> ⚠️ Don't start the file with `flush ruleset`. It deletes *every* table - including the
> rules Docker, Kubernetes or fail2ban put there (in this Docker lab: the embedded DNS rules).
> Flush only your own table: `table inet filter` + `flush table inet filter`.

The checker builds a fake "client" in a network namespace and actually tries to connect
from `192.168.77.2` (outside) and `10.199.0.2` (monitoring network).

## Commands to learn

`nft list ruleset` `nft -c -f FILE` (check only) `nft -f FILE` `nft list chain inet filter input`
`nft add rule ...` `nft -a list ...` (handles) `nft delete rule ... handle N` `systemctl enable nftables`
`ss -tlnp` `nc -zv` `curl --interface` `ip netns` - and the legacy world: `iptables -L -n -v`, `ufw`

## Done when

`lab check i07` passes.

## Explore (not graded)

- Add `counter` to your rules and watch them with `nft list ruleset` while you send traffic.
- Log dropped packets: `limit rate 5/minute log prefix "nft-drop: "` before the policy kicks in.
  Read them with `journalctl -k`.
- Rewrite the ruleset with named **sets** (`set allowed_tcp { type inet_service; elements = {...} }`).
- How would you do the same with `ufw`? What does `ufw` generate under the hood?
