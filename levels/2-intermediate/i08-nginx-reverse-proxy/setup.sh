#!/usr/bin/env bash
# i08 setup: a private backend on 127.0.0.1:5000 and some static files
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd nginx
prepare_answers
bash "$LAB_DIR/cleanup.sh"

install_app /opt/lab/i08/backend.py
cat > /etc/systemd/system/i08-backend.service <<'UNIT'
[Unit]
Description=Backend app for lab i08
[Service]
DynamicUser=yes
ExecStart=/usr/bin/python3 /opt/lab/i08/backend.py --name backend --bind 127.0.0.1 --port 5000
Restart=on-failure
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now i08-backend.service >/dev/null 2>&1

mkdir -p /opt/lab/i08/static
echo "logo-$(od -An -N3 -tx1 /dev/urandom | tr -d ' \n')" > /opt/lab/i08/static/logo.txt
for i in $(seq 1 80); do echo ".rule-$i { margin: ${i}px; padding: 0 ${i}px; color: #333; }"; done > /opt/lab/i08/static/style.css
chmod -R a+rX /opt/lab/i08

# Start from the distro default: default site enabled, nginx stopped
[[ -e /etc/nginx/sites-enabled/default || ! -e /etc/nginx/sites-available/default ]] ||
  ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
systemctl disable --now nginx >/dev/null 2>&1
info "backend: curl -s 127.0.0.1:5000/health"
