# b08 · Solution

```bash
# Aliases and functions: ~/.bashrc
cat >> ~/.bashrc <<'RC'

# --- lab b08 ---
alias ports='ss -tulpn'
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
RC

# Environment for login shells: ~/.profile
cat >> ~/.profile <<'RC'

# --- lab b08 ---
export PATH="$PATH:/opt/tools/bin"
export EDITOR=vim
RC

# Load into the current shell
source ~/.profile

# stdout and stderr to different files
labtool > ~/answers/b08-out.txt 2> ~/answers/b08-err.txt
```

## Why

- Interactive non-login shells (a new terminal tab) read `~/.bashrc`. Login shells (ssh, `su -`)
  read `~/.profile`, which on Debian/Ubuntu sources `~/.bashrc`. Environment goes where both see it.
- `cd` inside a script only changes the script's directory. Functions run in *your* shell.
- Redirections are processed left to right: `2>&1 > file` points stderr at the *old* stdout
  (the terminal) before stdout moves to the file.
