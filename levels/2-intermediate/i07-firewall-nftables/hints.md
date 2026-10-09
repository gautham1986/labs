Skeleton:
```
#!/usr/sbin/nft -f
table inet filter
flush table inet filter

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        # your rules here, first match wins
    }
}
```
Check syntax with `sudo nft -c -f /etc/nftables.conf` before loading with `sudo nft -f`.
---
Connection tracking: `ct state established,related accept` and `ct state invalid drop`.
Loopback: `iif "lo" accept`. ICMP: `meta l4proto { icmp, ipv6-icmp } accept`.
---
Rate-limited SSH: `tcp dport 22 ct state new limit rate 10/minute accept` - new connections above
the limit fall through to the policy (drop). Established ones are already accepted above.
---
`tcp dport { 80, 443, 8080 } accept` and `ip saddr 10.0.0.0/8 tcp dport 9100 accept`.
---
Persistence: the `nftables` service loads `/etc/nftables.conf` at boot:
`sudo systemctl enable nftables`. (`restart` re-applies the file now.)
