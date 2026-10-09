# i07 · Solution

```bash
sudo tee /etc/nftables.conf > /dev/null <<'NFT'
#!/usr/sbin/nft -f
# Host firewall - default deny inbound.
# Only manage our own table; never `flush ruleset` (it wipes Docker/k8s/fail2ban rules).
table inet filter
flush table inet filter

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        ct state established,related accept
        ct state invalid drop
        iif "lo" accept
        meta l4proto { icmp, ipv6-icmp } accept

        tcp dport 22 ct state new limit rate 10/minute accept
        tcp dport { 80, 443, 8080 } accept
        ip saddr 10.0.0.0/8 tcp dport 9100 accept

        counter comment "dropped by policy"
    }
    chain forward {
        type filter hook forward priority 0; policy accept;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
NFT

sudo nft -c -f /etc/nftables.conf      # syntax check first
sudo nft -f /etc/nftables.conf
sudo systemctl enable nftables
sudo nft list chain inet filter input
```

## Why

- Default deny + explicit allows is the only firewall posture you can reason about.
- Rule order matters: accept established traffic first (cheap, and most packets), then specific
  services.
- `forward` stays `accept` here because Docker/containers on a real host route through it; on a
  plain server you'd usually drop it too.
- The rate limit slows brute-force attempts. Real setups add fail2ban/sshguard or allow SSH only
  from a bastion/VPN range.
