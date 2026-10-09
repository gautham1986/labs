# b05 · Package management (apt/dpkg)

**Level:** Beginner · **Time:** ~20 min · **Needs:** internet access

## Scenario

You need a couple of tools on this box, and someone asks you which package a binary came
from and what version of bash is installed (a CVE was just announced). You also want to pin
a package so an unattended upgrade doesn't change it.

## Tasks

1. Install the packages `tree` and `ncdu`.
2. Find which **package** installed the file `/usr/bin/pgrep`. Write the package name to
   `~/answers/b05-owner.txt`.
3. Write the exact **installed version** of the `bash` package (e.g. `5.2.21-2ubuntu4`) to
   `~/answers/b05-bashver.txt`.
4. Put the `ncdu` package **on hold** so `apt upgrade` won't touch it.

## Commands to learn

`apt update` `apt install` `apt remove` vs `apt purge` `apt search` `apt show` `apt list --installed`
`apt-cache policy` `apt-mark hold|unhold|showhold` `dpkg -l` `dpkg -L pkg` `dpkg -S /path`
`dpkg-query -W -f='${Version}\n' pkg`

> On RHEL/Fedora the equivalents are `dnf install`, `rpm -qf /path`, `rpm -q pkg`,
> `dnf versionlock`. Worth knowing both families for interviews.

## Done when

`lab check b05` passes.

## Explore (not graded)

- `dpkg -L tree` - every file a package installed. Where did the man page go?
- `apt-cache policy nginx` - what's the difference between "Installed" and "Candidate"?
- Where does apt keep its sources? Look in `/etc/apt/sources.list.d/`. Read about the
  `Signed-By:` field and why `apt-key` is deprecated.
- `apt-get install --simulate nginx-extras` - read the plan without changing anything.
- Try `dpkg -S /usr/bin/ss`, then `dpkg -S /bin/ss`. Why does only one work? Look up "usrmerge"
  and `ls -l /bin`.
