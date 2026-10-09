# b06 · Processes, signals & job control

**Level:** Beginner · **Time:** ~30 min · **Needs:** any Linux

## Scenario

The box feels sluggish. Someone left processes running that shouldn't be, a batch job is
competing with production, and a monitoring alert says there's a zombie process.

## Tasks

1. Something is burning a full CPU core. Find the process, write its **name** to
   `~/answers/b06-hog.txt`, then **kill** it.
2. `report-gen` is a low-priority batch job. Change its niceness to **15** without restarting it.
3. There is a **zombie** process. Write the **PID of its parent** to `~/answers/b06-zparent.txt`,
   then get rid of the zombie.
4. `config-watcher` re-reads its config when it receives **SIGHUP**. Make it reload its config
   **without stopping it**. (It logs to `/var/log/b06-config-watcher.log`.)

## Commands to learn

`ps aux` `ps -eo pid,ppid,stat,ni,pcpu,comm --sort=-pcpu` `ps -ef --forest` `pstree -p`
`top` / `htop` (sort by CPU, press `k` to kill) `pgrep -a` `pkill` `kill -l` `kill -TERM/-KILL/-HUP`
`nice` `renice` `jobs` `bg` `fg` `Ctrl-Z` `&` `nohup` `disown` `/proc/<pid>/`

## Done when

`lab check b06` passes.

## Explore (not graded)

- Process states in `ps` STAT: `R` running, `S` sleeping, `D` uninterruptible (usually I/O),
  `Z` zombie, `T` stopped. Why can't you `kill -9` a zombie?
- Run `sleep 300`, press `Ctrl-Z`, then `bg`, `jobs`, `fg`. What signals were sent?
- `ls -l /proc/$(pgrep -x report-gen)/` - look at `cmdline`, `status`, `fd/`, `cwd`, `environ`.
- Why is `kill -9` a last resort? What does a program get to do on `SIGTERM` that it can't on
  `SIGKILL`?
