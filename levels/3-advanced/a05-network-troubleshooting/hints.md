Read the client and its config first: `cat /opt/lab/a05/client.sh /etc/lab/a05/client.conf`.
Then test each piece separately: does the name resolve (`getent hosts api.lab.internal`)? To what?
Is anything listening there?
---
`api.lab.internal` resolves via `/etc/hosts`. The API listens on 127.0.0.1 only
(`sudo ss -tlnp | grep 9090`). Fix the hosts entry.
---
"Connection refused" right away? Compare the port in the config with the port the API listens on.
---
Still a timeout to 127.0.0.1:9090 even though `ss` shows a listener? Something is dropping packets.
`sudo nft list ruleset` - look beyond the obvious table names. Delete only the offending rule
(`sudo nft -a list ruleset` shows rule handles) or the leftover table.
