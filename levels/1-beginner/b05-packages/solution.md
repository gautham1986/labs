# b05 · Solution

```bash
sudo apt-get update
sudo apt-get install -y tree ncdu

dpkg -S /usr/bin/pgrep                              # procps: /usr/bin/pgrep
dpkg -S /usr/bin/pgrep | cut -d: -f1 > ~/answers/b05-owner.txt

dpkg-query -W -f='${Version}\n' bash > ~/answers/b05-bashver.txt

sudo apt-mark hold ncdu
apt-mark showhold
```

## Why

- `apt` is the friendly front end; `apt-get`/`apt-cache` have a stable output format for scripts.
- `dpkg` is the low-level tool that knows what's *installed*; apt knows what's *available*.
- Holding packages is how you keep a known-good version of something critical (a database,
  a kernel) while still patching everything else. Document every hold - forgotten holds are
  how servers end up years out of date.
