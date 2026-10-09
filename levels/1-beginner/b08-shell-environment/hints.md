Aliases and functions go in `~/.bashrc` (read by every interactive shell). After editing,
run `source ~/.bashrc` to load it into your current shell.
---
PATH and exported variables usually go in `~/.profile` (read by login shells; on Ubuntu it
also sources `~/.bashrc`). Prepend or append, but keep the old value:
`export PATH="$PATH:/opt/tools/bin"`
---
A function that changes directory must be a shell function, not a script (a script runs in a
child process, and its `cd` dies with it):
`mkcd() { mkdir -p -- "$1" && cd -- "$1"; }`
---
File descriptor 1 is stdout, 2 is stderr: `labtool > ~/answers/b08-out.txt 2> ~/answers/b08-err.txt`
