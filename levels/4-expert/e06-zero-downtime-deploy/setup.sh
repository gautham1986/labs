#!/usr/bin/env bash
# e06 setup: two colors, three releases, nginx in front
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd nginx curl
prepare_answers
bash "$LAB_DIR/cleanup.sh"

R=/opt/lab/e06/releases
install_app /opt/lab/e06/app.py
mkdir -p $R/{v1,v2,v3-broken} /etc/e06
echo 'ARGS="--version v1 --warmup 2"' > $R/v1/release.env
echo 'ARGS="--version v2 --warmup 3"' > $R/v2/release.env
echo 'ARGS="--version v3-broken --warmup 1 --fail-health"' > $R/v3-broken/release.env
cat > /opt/lab/e06/run-release.sh <<'RUN'
#!/usr/bin/env bash
# started by app@<color>.service: loads the release and runs it on the color's port
set -euo pipefail
source "/opt/lab/e06/releases/$RELEASE/release.env"
# shellcheck disable=SC2086
exec /usr/bin/python3 /opt/lab/e06/app.py --name "app-$COLOR" --bind 127.0.0.1 --port "$PORT" $ARGS
RUN
chmod 755 /opt/lab/e06/run-release.sh
printf 'PORT=7001\nRELEASE=v1\n' > /etc/e06/blue.env
printf 'PORT=7002\nRELEASE=v1\n' > /etc/e06/green.env

cat > /etc/systemd/system/app@.service <<'UNIT'
[Unit]
Description=Shop app, %i color (lab e06)

[Service]
Environment=COLOR=%i
EnvironmentFile=/etc/e06/%i.env
ExecStart=/opt/lab/e06/run-release.sh
DynamicUser=yes
Restart=on-failure
RestartSec=1
UNIT

echo 'server 127.0.0.1:7001;' > /etc/nginx/e06-upstream.conf
cat > /etc/nginx/sites-available/e06.conf <<'NGINX'
upstream e06_app {
    include /etc/nginx/e06-upstream.conf;
}
server {
    listen 8086;
    location / {
        proxy_pass http://e06_app;
        proxy_connect_timeout 1s;
    }
}
NGINX
ln -sfn /etc/nginx/sites-available/e06.conf /etc/nginx/sites-enabled/e06.conf
nginx_ipv6_guard
systemctl daemon-reload
systemctl start app@blue
systemctl enable nginx >/dev/null 2>&1; systemctl restart nginx
wait_for 15 curl -fsS -m 1 localhost:8086/health || warn "blue didn't come up - check: journalctl -u app@blue"
info "live version: $(curl -s localhost:8086/version)"
