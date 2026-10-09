Octal digits are owner/group/others, each = r(4) + w(2) + x(1). `750` = rwx r-x ---.
`chown root:webops FILE` sets both owner and group in one go.
---
For directories, `x` means "may enter/traverse". A directory with mode 644 can't be entered,
which is why `chmod -R 644` breaks trees. Use `find` to treat files and directories separately:
`find /srv/b04/public -type d -exec chmod 755 {} +` and the same with `-type f` and `644`.
---
The sticky bit is the leading `1` in `1777`. On a directory it means "only the file's owner
(or root) can delete or rename it".
---
ACLs: `setfacl -m u:webdev:r /srv/b04/logs/app.log`, check with `getfacl`. The user also needs
to be able to *enter* `/srv/b04/logs` - check that directory's mode.
---
For the answers: `rwxr-x---` -> 7,5,0. For `0754`: 7=rwx, 5=r-x, 4=r--.
