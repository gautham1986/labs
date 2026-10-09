# b08 · Shell environment, dotfiles & redirection

**Level:** Beginner · **Time:** ~30 min · **Needs:** any Linux

## Scenario

You'll live in this shell for years - make it yours. Your team also installed internal tools
in `/opt/tools/bin`, and one of them (`labtool`) mixes useful output with error noise.

## Tasks

All changes must **persist** (survive logging out and back in), so put them in your dotfiles.

1. Add an alias `ports` that runs `ss -tulpn`.
2. Add `/opt/tools/bin` to your `PATH` so you can run `labtool` from anywhere.
3. Set the environment variable `EDITOR` to `vim` (exported, so programs like `crontab -e` see it).
4. Add a shell function `mkcd` that creates a directory (including parents) and `cd`s into it:
   `mkcd ~/a/b/c` -> you are now in `~/a/b/c`.
5. Run `labtool` **once** and, in that single command, save its normal output (stdout) to
   `~/answers/b08-out.txt` and its errors (stderr) to `~/answers/b08-err.txt`.

## Commands to learn

`echo $PATH` `export` `env` `printenv` `alias` `type` `which` `command -v` `source ~/.bashrc`
`>` `>>` `2>` `2>&1` `&>` `|` `tee` `< file` `<<EOF` `$?`
Files: `~/.bashrc` (interactive shells) vs `~/.profile` (login shells), `/etc/profile.d/`

## Done when

`lab check b08` passes (it starts fresh shells, so make sure your changes are in files).

## Explore (not graded)

- Run `labtool > out.txt 2>&1` and `labtool 2>&1 > out.txt`. Why are the results different?
- What's the difference between `VAR=x` and `export VAR=x`? Test with `bash -c 'echo $VAR'`.
- Customize your prompt (`PS1`) to show the exit code of the last command in red when non-zero.
- `set -o vi` or learn Emacs keys: `Ctrl-A`, `Ctrl-E`, `Ctrl-R` (reverse search), `Alt-.` (last arg).
- `history | awk '{print $2}' | sort | uniq -c | sort -rn | head` - your most-used commands.
