# b04 · File permissions, ownership & ACLs

**Level:** Beginner · **Time:** ~30 min · **Needs:** any Linux

## Scenario

A web app was deployed to `/srv/b04` by someone who ran `chmod -R 777` "to make it work",
then got nervous and changed a few things at random. Security wants it locked down properly.
Users: `webdev` (a developer, in group `webops`). Group: `webops`.

```
/srv/b04/
├── bin/deploy.sh        # deploy script
├── secrets/db.env       # database password
├── uploads/             # users upload files here
├── public/              # static website (files + subdirectories)
└── logs/app.log         # application log
```

## Tasks

1. `bin/deploy.sh`: owner `root`, group `webops`, mode `750` (owner rwx, group rx, others nothing).
2. `secrets/`: directory mode `700`, owner `root`. `secrets/db.env`: mode `600`, owner `root`.
3. `uploads/`: everyone can create files, but users **must not be able to delete each other's
   files** (mode `1777`).
4. `public/`: **every directory** must be `755` and **every file** `644`, recursively.
   (Hint: `chmod -R 644` would break the directories - why?)
5. Give user `webdev` **read** access to `logs/app.log` with an **ACL**, without changing its
   owner, group or mode bits (which must stay `root:root 640`).
6. Write the octal mode for `rwxr-x---` to `~/answers/b04-octal.txt` and the symbolic form
   (like `rwxr-x---`) for mode `0754` to `~/answers/b04-symbolic.txt`.

## Commands to learn

`ls -l` `stat -c '%a %U:%G %n'` `chmod` (octal and `u+x,g-w,o=`) `chown user:group` `chgrp`
`find -type d -exec chmod 755 {} +` `umask` `setfacl -m u:NAME:r` `getfacl`
Special bits: setuid `4xxx`, setgid `2xxx`, sticky `1xxx`

## Done when

`lab check b04` passes.

## Explore (not graded)

- Run `umask`. Create a file and a directory - why are their default modes different?
- `ls -ld /tmp` - spot the `t`. Why does `/tmp` need the sticky bit?
- After adding the ACL, `ls -l logs/app.log` shows a `+`. What does `getfacl` show as the "mask"?
- Find all world-writable files on the system: `sudo find / -xdev -type f -perm -0002 2>/dev/null`
