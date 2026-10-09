# a05 · Solution

Three stacked faults: wrong `/etc/hosts` entry (timeout), wrong port in the client config
(refused), and a leftover nftables rule silently dropping traffic to 9090 (timeout).

```bash
cat /opt/lab/a05/client.sh /etc/lab/a05/client.conf
/opt/lab/a05/client.sh || true

# Layer 1: name resolution - points at an unroutable IP
getent hosts api.lab.internal
sudo ss -tlnp | grep 9090                                   # API is on 127.0.0.1
grep -v 'api.lab.internal' /etc/hosts > /tmp/hosts.new
echo '127.0.0.1  api.lab.internal' >> /tmp/hosts.new
sudo cp /tmp/hosts.new /etc/hosts                           # cp keeps the inode (Docker bind-mounts /etc/hosts)

# Layer 2: port - "connection refused"
/opt/lab/a05/client.sh || true
sudo sed -i 's/:9091/:9090/' /etc/lab/a05/client.conf

# Layer 3: filtering - timeout to a port that is listening
/opt/lab/a05/client.sh || true
sudo nft list ruleset
sudo nft delete table inet legacy_filter

/opt/lab/a05/client.sh

cat > ~/answers/a05-rootcauses.txt <<'TXT'
/etc/hosts mapped api.lab.internal to 10.255.255.1 (unroutable) instead of 127.0.0.1 -> timeouts
client.conf pointed at port 9091; the API listens on 9090 -> connection refused
leftover nftables table legacy_filter dropped output to 127.0.0.1:9090 -> timeouts
TXT
```

## Why

- Change one variable at a time and re-test; stacked faults hide each other.
- The *symptom changing* (timeout -> refused -> timeout) is progress, not failure.
- `sed -i` on `/etc/hosts` fails inside Docker (it's a bind mount and `sed -i` replaces the
  file); writing in place with `cp`/`tee` works everywhere.
