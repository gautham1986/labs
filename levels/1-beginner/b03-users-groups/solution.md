# b03 · Solution

```bash
sudo groupadd devops
sudo groupadd auditors

sudo useradd -m -s /bin/bash -G devops alice
sudo useradd -m -s /bin/bash -G devops bob
sudo usermod -aG sudo alice                 # -a = append! never forget it

sudo chage -E 2030-12-31 bob
sudo chage -l bob | grep 'Account expires'

sudo useradd -m -s /bin/bash -G auditors carol

sudo useradd -r -s /usr/sbin/nologin -d /var/lib/appsvc -m appsvc

sudo mkdir -p /srv/devops
sudo chown root:devops /srv/devops
sudo chmod 2770 /srv/devops
ls -ld /srv/devops     # drwxrws--- root devops
id alice; id bob; getent passwd appsvc
```

## Why

- `useradd` is the low-level, script-friendly tool. `adduser` (Debian) is an interactive wrapper.
- Supplementary groups (`-G`) give extra permissions; the primary group (`-g`) is what new files get.
- System accounts (`-r`) are for daemons: low UID, no password, no login shell. Running services
  as dedicated users limits the blast radius of a compromise.
- setgid on a directory (`2xxx`) makes collaboration work: every new file belongs to the team
  group instead of each user's private group.
