#!/usr/bin/env bash
# i02 setup: a noisy worker service, an audit logger, and a log file nobody rotates
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd logrotate logger
prepare_answers
bash "$LAB_DIR/cleanup.sh"

fail_id=$(printf 'ORD-%05d' $((RANDOM % 100000)))
users=(maria devon kenji priya oscar)
refund_user=${users[RANDOM % ${#users[@]}]}

mkdir -p /opt/lab/i02 /var/log/orders
cat > /opt/lab/i02/orders-worker.sh <<'WORKER'
#!/usr/bin/env bash
# Simulated batch worker. Usage: orders-worker.sh <failing-order-id> <refund-user>
fail_id=$1 refund_user=$2
for i in $(seq 1 400); do
  id=$(printf 'ORD-%05d' $((RANDOM % 100000)))
  if (( RANDOM % 15 == 0 )); then
    echo "WARN slow response from payment provider for $id"
  else
    echo "INFO processed order $id"
  fi
  (( i == 173 )) && echo "<3>ERROR payment failed for order $fail_id: card declined (code 51)"
  (( i == 288 )) && logger -t orders-audit -p auth.notice "refund issued for $id by user $refund_user"
  echo "$(date '+%F %T') order $id status=ok" >> /var/log/orders/orders.log
done
echo "batch complete - idling"
exec sleep infinity
WORKER
chmod 755 /opt/lab/i02/orders-worker.sh

cat > /etc/systemd/system/orders-worker.service <<UNIT
[Unit]
Description=Orders batch worker (lab i02)

[Service]
ExecStart=/opt/lab/i02/orders-worker.sh $fail_id $refund_user

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl start orders-worker.service
sleep 3

expect_set i02 order "$fail_id"
expect_set i02 refund-user "$refund_user"
