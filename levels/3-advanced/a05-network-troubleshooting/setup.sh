#!/usr/bin/env bash
# a05 setup: an API on 127.0.0.1:9090 and a client with three stacked faults in front of it
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd nft curl
prepare_answers
bash "$LAB_DIR/cleanup.sh"

install_app /opt/lab/a05/api.py
cat > /etc/systemd/system/inventory-api.service <<'UNIT'
[Unit]
Description=Inventory API (lab a05)
[Service]
DynamicUser=yes
ExecStart=/usr/bin/python3 /opt/lab/a05/api.py --name inventory --bind 127.0.0.1 --port 9090
Restart=on-failure
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now inventory-api >/dev/null 2>&1

mkdir -p /etc/lab/a05
echo 'API_URL=http://api.lab.internal:9091/health' > /etc/lab/a05/client.conf
cat > /opt/lab/a05/client.sh <<'C'
#!/usr/bin/env bash
# inventory client - DO NOT EDIT, fix the environment instead
source /etc/lab/a05/client.conf
if out=$(curl -fsS -m 4 "$API_URL" 2>&1) && grep -q '"status": "ok"' <<< "$out"; then
  echo "inventory: OK"
else
  echo "inventory: ERROR - $out" >&2
  exit 1
fi
C
chmod 755 /opt/lab/a05/client.sh
mkdir -p "$LAB_VAR"
sha256sum /opt/lab/a05/client.sh > "$LAB_VAR/a05-client.sha256"

# Fault 1: stale hosts entry
tmp=$(grep -v 'api\.lab\.internal' /etc/hosts); printf '%s\n10.255.255.1  api.lab.internal\n' "$tmp" > /etc/hosts
# Fault 3: a "temporary" firewall rule from the change window
nft -f - <<'NFT'
table inet legacy_filter {
    chain out {
        type filter hook output priority 0; policy accept;
        ip daddr 127.0.0.1 tcp dport 9090 drop comment "CHG-4711 temp block"
    }
}
NFT
