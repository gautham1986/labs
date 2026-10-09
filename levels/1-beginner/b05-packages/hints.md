Package indexes can be stale in a fresh container: run `sudo apt update` before installing.
---
`dpkg -S /usr/bin/pgrep` searches installed packages for a file and prints `package: path`.
Only write the package name to the answer file.
---
`dpkg-query -W -f='${Version}\n' bash` prints just the version. `apt-cache policy bash`
shows it too, next to "Installed:".
---
`sudo apt-mark hold ncdu` and verify with `apt-mark showhold`.
