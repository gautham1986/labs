#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
CONF=/etc/logrotate.d/orders

journald_setting() { systemd-analyze cat-config systemd/journald.conf 2>/dev/null | grep -Eq "^$1"; }
journal_on_disk() { find /var/log/journal -name '*.journal' 2>/dev/null | grep -q .; }
dropin_used() { ls /etc/systemd/journald.conf.d/*.conf >/dev/null 2>&1; }
directive() { grep -Eq "^[[:space:]]*$1([[:space:]]|$)" "$CONF"; }
rotation_works() {
  local st; st=$(mktemp)
  [[ -s /var/log/orders/orders.log ]] || echo "$(date) check" >> /var/log/orders/orders.log
  logrotate -f -s "$st" "$CONF" && rm -f "$st" && [[ -f /var/log/orders/orders.log.1 || -f /var/log/orders/orders.log.1.gz ]] &&
    [[ "$(stat -c '%a %U %G' /var/log/orders/orders.log)" == "640 root adm" ]]
}
logged_warning() { journalctl -t lab-i02 -p warning -o cat --no-pager | grep -q 'hello from i02'; }

section "Investigation"
check_answer "order ID with the failed payment" i02 order
check_answer "user who issued the refund" i02 refund-user

section "journald"
check "configured via a drop-in in /etc/systemd/journald.conf.d/" dropin_used
check "Storage=persistent" journald_setting 'Storage=persistent'
check "SystemMaxUse=200M" journald_setting 'SystemMaxUse=200M'
check "journal files are being written to /var/log/journal" journal_on_disk

section "logrotate"
check "/etc/logrotate.d/orders exists" file_exists "$CONF"
check "config is valid (logrotate -d)" logrotate -d "$CONF"
for d in daily 'rotate 7' compress delaycompress missingok notifempty 'create 0?640 root adm'; do
  check "directive: $d" directive "$d"
done
check "forced rotation works and recreates orders.log as 0640 root:adm" rotation_works

section "Writing logs"
check "journal has 'hello from i02' with tag lab-i02 at priority warning" logged_warning

finish
