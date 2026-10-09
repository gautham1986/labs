# shellcheck shell=sh
# /etc/profile.d/zz-lab.sh - environment for the practice lab (sourced by login shells)
export LAB_ROOT="${LAB_ROOT:-/lab}"
case ":$PATH:" in *":$LAB_ROOT:"*) ;; *) PATH="$LAB_ROOT:$PATH" ;; esac
export PATH

# Bash completion for the `lab` command
if [ -n "${BASH_VERSION:-}" ] && [ -f "$LAB_ROOT/lib/completion.bash" ]; then
  . "$LAB_ROOT/lib/completion.bash"
fi

# One-line welcome on interactive login shells
case $- in *i*)
  if [ -z "${LAB_WELCOMED:-}" ] && [ -x "$LAB_ROOT/lab" ]; then
    export LAB_WELCOMED=1
    printf '\n  \033[1mLinux SRE Lab\033[0m  ·  lab list  ·  lab start b01  ·  lab help\n\n'
  fi
;; esac
