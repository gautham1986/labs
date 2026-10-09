#!/usr/bin/env bash
# e01 setup: nginx -> shop with three stacked faults
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd nginx
prepare_answers
bash "$LAB_DIR/cleanup.sh"

id shop >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin shop
install_app /opt/lab/e01/shop.py
mkdir -p /var/lib/shop/cache
mount -t tmpfs -o size=1M,mode=0755 shop-cache /var/lib/shop/cache || die "could not mount tmpfs"
chown shop:shop /var/lib/shop/cache
head -c 1048576 /dev/zero > /var/lib/shop/cache/stale-sessions.bin 2>/dev/null || true
chown shop:shop /var/lib/shop/cache/stale-sessions.bin
touch -d '40 days ago' /var/lib/shop/cache/stale-sessions.bin

cat > /etc/systemd/system/shop.service <<'UNIT'
[Unit]
Description=Shop web app
After=network.target

[Service]
User=shop
ExecStart=/usr/bin/python3 /opt/lab/e01/shop.py --name shop --bind 127.0.0.1 --port 5050 --write /var/lib/shop/cache/warmup.json --write-bytes 200000 --slow /products=2
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

cat > /etc/nginx/sites-available/shop.conf <<'NGINX'
upstream shop_backend {
    server 127.0.0.1:5005;
}

server {
    listen 8088;
    server_name shop.example.com _;

    location / {
        proxy_pass http://shop_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 2s;
        proxy_read_timeout 1s;
    }
}
NGINX
ln -sfn /etc/nginx/sites-available/shop.conf /etc/nginx/sites-enabled/shop.conf
nginx_ipv6_guard
systemctl daemon-reload
systemctl enable shop.service >/dev/null 2>&1
systemctl restart shop.service >/dev/null 2>&1
nginx -t >/dev/null 2>&1 && { systemctl enable nginx >/dev/null 2>&1; systemctl restart nginx; }
sleep 1
info "curl -s -o /dev/null -w '%{http_code}\\n' localhost:8088/  ->  $(curl -s -o /dev/null -w '%{http_code}' localhost:8088/)"
