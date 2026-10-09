`ls` hides files that start with a dot. `ls -a` shows them - but there are a lot of
directories to look through. Let `find` do the walking: `find /opt/lab/b01/maze -name '...'`
---
For the secret: `find /opt/lab/b01/maze -name .treasure`, then `cat` the result. To write only
the code, you can use `cut -d= -f2` or just type it: `echo LNX-XXXXXX > ~/answers/b01-secret.txt`
---
For counting: `find ... -type f -name '*.log'` lists only regular files. Pipe it into `wc -l`.
There is a *directory* with a `.log` name in there - `-type f` is what skips it.
---
For the largest file: `find /opt/lab/b01/maze -type f -printf '%s %p\n' | sort -n | tail -1`
gives "size path". Or `du -a /opt/lab/b01/maze | sort -n | tail`. Remember: `-printf %p`
prints the path as you gave it to find, so start find from an absolute path.
---
For the project skeleton: brace expansion builds all four paths at once:
`mkdir -p ~/projects/webapp/{src,tests,docs,config}` then `touch ~/projects/webapp/README.md`.
