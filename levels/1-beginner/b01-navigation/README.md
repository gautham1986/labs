# b01 · Navigating the filesystem

**Level:** Beginner · **Time:** ~20 min · **Needs:** any Linux

## Scenario

A previous admin left a messy directory tree at `/opt/lab/b01/maze`. Somewhere in it is a
hidden file with a secret code, plus a pile of log files and one suspiciously large file.
Find your way around using only the shell.

## Tasks

1. Find the **hidden** file named exactly `.treasure` somewhere under `/opt/lab/b01/maze`.
   It contains a line `SECRET=<code>`. Write just the code (e.g. `LNX-1A2B3C`) to
   `~/answers/b01-secret.txt`.
2. Count the **regular files** whose name ends in `.log` anywhere under the maze
   (directories don't count). Write the number to `~/answers/b01-logcount.txt`.
3. Find the **largest file** under the maze and write its **absolute path** to
   `~/answers/b01-largest.txt`.
4. Create this structure in your home directory with **one** `mkdir` command, then add an
   empty `README.md` inside `webapp`:
   ```
   ~/projects/webapp/
   ├── README.md
   ├── config/
   ├── docs/
   ├── src/
   └── tests/
   ```

> `~/answers` is a shortcut to `workspace/answers` in this repo, so you can also see your
> answers from your host machine.

## Commands to learn

`pwd` `cd` (`cd -`, `cd ~`, `cd ..`) `ls -la` `ls -lhS` `tree -a` (after b05) `find` (`-name`,
`-type`, `-size`, `-printf`) `du -ah` `sort -h` `wc -l` `mkdir -p` with brace expansion `{a,b}`
`touch` `cat` `file` `stat` `echo ... > file`

## Done when

`lab check b01` passes.

## Explore (not graded)

- `man hier` - why Linux puts things in `/etc`, `/var`, `/opt`, `/usr/local`, `/srv`.
- What's the difference between `find . -name '*.log' | wc -l` and `ls -R | grep -c .log`?
  Which one is correct, and why?
- Use `find` with `-printf '%s %p\n'` and compare it to `du -a`. Why can they disagree?
- Try `cd /opt/lab/b01/maze/north` then `cd -`. What's `$OLDPWD`?
