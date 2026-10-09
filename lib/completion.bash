# shellcheck shell=bash
# Bash completion for the `lab` command. Sourced from /etc/profile.d/zz-lab.sh.
_lab_complete() {
  local cur=${COMP_WORDS[COMP_CWORD]} root=${LAB_ROOT:-/lab}
  if (( COMP_CWORD == 1 )); then
    mapfile -t COMPREPLY < <(compgen -W "list start show check hint solution reset clean progress doctor path help" -- "$cur")
    return
  fi
  case ${COMP_WORDS[1]} in
    start|show|check|hint|solution|reset|clean|path)
      local ids
      ids=$( { find "$root/levels" -mindepth 2 -maxdepth 2 -type d -printf '%f\n'
               find "$root/scripting/exercises" -mindepth 1 -maxdepth 1 -type d -printf '%f\n'; } 2>/dev/null \
             | grep -E '^[a-z][0-9]+-' | cut -d- -f1)
      mapfile -t COMPREPLY < <(compgen -W "$ids" -- "$cur") ;;
    list)
      mapfile -t COMPREPLY < <(compgen -W "beginner intermediate advanced expert scripting" -- "$cur") ;;
  esac
}
complete -F _lab_complete lab
