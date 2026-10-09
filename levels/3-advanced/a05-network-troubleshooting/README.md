# a05 · "It can't reach the API" - network troubleshooting

**Level:** Advanced · **Time:** ~40 min · **Needs:** systemd, nftables

## Scenario

🚨 *"The inventory client on lab has been failing since the network change window."*

```
/opt/lab/a05/client.sh   -> reads /etc/lab/a05/client.conf -> calls the inventory API
inventory-api.service    -> the API itself, listens on 127.0.0.1:9090 (deliberately local-only)
```

Run `/opt/lab/a05/client.sh`. It should print `inventory: OK`. It doesn't.
Work **layer by layer**: name resolution -> routing -> port -> filtering -> application.
There are several faults stacked on top of each other.

## Tasks

1. Make `/opt/lab/a05/client.sh` print `inventory: OK`.
2. Fix things where they're broken - **don't** work around them: don't change the API to
   listen on `0.0.0.0`, don't edit `client.sh`, don't flush the whole firewall.
3. Write each root cause you found, one per line, to `~/answers/a05-rootcauses.txt`.

## Commands to learn

`getent hosts NAME` `ip route get IP` `ping` `curl -v` `curl -w '%{time_connect}'`
`nc -zv HOST PORT` `ss -tlnp` `nft list ruleset` `nft -a list table ...` `nft delete rule ... handle N`
`tcpdump -ni lo port 9090` `timeout 3 bash -c '</dev/tcp/HOST/PORT'`

**Timeout vs. refused** is the most useful distinction in network debugging:
*refused* = packet arrived, nothing listening (or a REJECT rule); *timeout* = packet went nowhere
(wrong IP/route, or silently DROPped).

## Done when

`lab check a05` passes.

## Explore (not graded)

- Run `sudo tcpdump -ni any port 9090` while the firewall rule is still in place. Do you see the
  SYN? Do you see a reply?
- Replace the `drop` with `reject` and compare `curl` behaviour.
- `ip route get 10.255.255.1` - where would that packet have gone?
