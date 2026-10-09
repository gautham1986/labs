# b04 · Solution

```bash
cd /srv/b04

# 1. deploy script
sudo chown root:webops bin/deploy.sh
sudo chmod 750 bin/deploy.sh

# 2. secrets
sudo chown -R root:root secrets
sudo chmod 700 secrets
sudo chmod 600 secrets/db.env

# 3. shared upload dir with sticky bit
sudo chmod 1777 uploads

# 4. directories 755, files 644 - treat them separately
sudo find public -type d -exec chmod 755 {} +
sudo find public -type f -exec chmod 644 {} +

# 5. ACL for one extra user, mode bits untouched
sudo setfacl -m u:webdev:r logs/app.log
getfacl logs/app.log
sudo -u webdev head -1 /srv/b04/logs/app.log    # proves it works

# 6. answers
echo 750 > ~/answers/b04-octal.txt
echo rwxr-xr-- > ~/answers/b04-symbolic.txt
```

## Why

- Least privilege: secrets readable by root only; scripts executable only by those who deploy.
- `x` on a directory = permission to traverse it. Files rarely need `x` unless they are programs.
- `find ... -exec cmd {} +` batches many paths into one command - much faster than `\;`.
- ACLs add exceptions without widening the group or "others" bits. Prefer groups for teams,
  ACLs for one-off grants.
