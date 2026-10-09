# s08 · Options with getopts, dry runs & retention

**Track:** Shell scripting · **Level:** Intermediate · **File:** `backup.sh`

## Spec

```
backup.sh -s SRC -d DEST [-k KEEP] [-n] [-h]
```
- Creates `DEST/<name>-YYYYmmdd-HHMMSS.tar.gz` where `<name>` is the basename of `SRC`. Paths
  inside the archive start with `<name>/` (never absolute). Creates `DEST` if needed.
- Then keeps only the newest `KEEP` (default **3**) archives **of that source** in `DEST`
  (other files in `DEST` are never touched) and prints `deleted PATH` for each removed archive.
- Prints `created PATH` for the new archive.
- `-n` = **dry run**: print `would create PATH` / `would delete PATH`, change nothing.
- `-h` = usage on stdout, exit 0.
- Errors: missing `-s`/`-d`, unknown option, or `KEEP` not a positive integer -> usage on stderr,
  exit **2**. `SRC` not a directory -> error, exit **1**.

## Concepts

`while getopts ':s:d:k:nh' opt` · `$OPTARG` · `shift $((OPTIND - 1))` · `:`/`?` cases
· `basename` / `${src%/}` · `tar -czf ... -C parent name` · `ls`-free retention with globs and sort
· a `run` wrapper for dry-run mode (see `scripting/templates/script-template.sh`)
