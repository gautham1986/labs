# i02 · Logs: journald, syslog & logrotate

**Level:** Intermediate · **Time:** ~35 min · **Needs:** systemd

## Scenario

The `orders-worker` service processed a batch overnight. Customer support says one payment
failed and someone issued a refund without a ticket. Find both in the logs, then fix the
logging setup: journal logs vanish on reboot, and `/var/log/orders/orders.log` grows forever.

## Tasks

1. Find the order ID whose **payment failed** in the `orders-worker` service logs. The worker
   logs hundreds of lines - filter by **priority** instead of scrolling. Write the ID
   (like `ORD-01234`) to `~/answers/i02-order.txt`.
2. A refund was logged by a separate audit logger with the syslog identifier (tag)
   `orders-audit`. Write the **user name** who issued it to `~/answers/i02-refund-user.txt`.
3. Make the journal **persistent** across reboots and cap it at **200M**, using a drop-in file in
   `/etc/systemd/journald.conf.d/` (don't edit the main `journald.conf`). Apply it.
4. Create `/etc/logrotate.d/orders` for `/var/log/orders/*.log`: rotate **daily**, keep **7**,
   **compress** (but delay compression by one cycle), don't fail if the log is **missing**,
   skip **empty** logs, and recreate the file as `0640 root adm`.
5. Write your own entry to the journal with tag `lab-i02`, priority **warning**, and the message
   `hello from i02`.

## Commands to learn

`journalctl -u UNIT` `-p err` `-t TAG` `-f` `-e` `-n 100` `--since "1 hour ago"` `-o json-pretty`
`-o cat` `-b` `--disk-usage` `--vacuum-size=` `logger -t TAG -p user.warning`
`systemd-analyze cat-config systemd/journald.conf` `logrotate -d` (dry run) `logrotate -f`
Files: `/var/log/`, `/var/log/journal/`, `/etc/logrotate.conf`, `/var/lib/logrotate/status`

## Done when

`lab check i02` passes. (The checker force-rotates `orders.log` once to prove your config works.)

## Explore (not graded)

- Syslog priorities: `emerg alert crit err warning notice info debug` (0-7). `-p err` shows
  0..3. How did a plain `echo` from the service end up at priority `err`? (Hint: `<3>` prefix,
  see `man sd-daemon`.)
- `journalctl -u orders-worker -o json-pretty -n 1` - every field is filterable, e.g.
  `_PID=`, `_SYSTEMD_INVOCATION_ID=`.
- `copytruncate` vs `create` + `postrotate` signals: which one can lose log lines, and when do
  you have to use it?
