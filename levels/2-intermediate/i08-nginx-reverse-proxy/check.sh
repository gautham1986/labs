#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
S=/opt/lab/i08/static

site_enabled() { [[ -L /etc/nginx/sites-enabled/i08.conf && "$(readlink -f /etc/nginx/sites-enabled/i08.conf)" == /etc/nginx/sites-available/i08.conf ]]; }
default_disabled() { [[ ! -e /etc/nginx/sites-enabled/default ]]; }
proxied() { curl -fsS -m 5 localhost/ | grep -q '"service": "backend"'; }
fwd_header() { curl -fsS -m 5 localhost/ | grep -iq "\"$1\": \"[^\"]"; }
static_ok() { [[ "$(curl -fsS -m 5 localhost/static/logo.txt)" == "$(cat $S/logo.txt)" ]]; }
health_ok() { [[ "$(curl -fsS -m 5 localhost/healthz | tr -d '\r\n')" == ok ]]; }
health_local() {  # healthz must not depend on the backend
  systemctl stop i08-backend; local rc=0
  [[ "$(curl -s -m 5 -o /dev/null -w '%{http_code}' localhost/healthz)" == 200 ]] || rc=1
  systemctl start i08-backend; sleep 1; return $rc
}
gzip_css() { curl -fsS -m 5 -H 'Accept-Encoding: gzip' -o /dev/null -D - localhost/static/style.css | grep -iq '^content-encoding: *gzip'; }
logged() {
  local tag; tag="/lab-check-$RANDOM$RANDOM"
  curl -s -m 5 -o /dev/null "localhost$tag"; sleep 0.5
  grep -q "$tag" /var/log/nginx/i08.access.log
}

section "nginx"
check "nginx -t passes" nginx -t
check "nginx is enabled" service_enabled nginx
check "nginx is running" service_active nginx
check "i08.conf enabled via symlink in sites-enabled/" site_enabled
check "default site disabled" default_disabled

section "Proxying"
check "GET / is proxied to the backend" proxied
check "backend receives X-Real-IP" fwd_header X-Real-IP
check "backend receives X-Forwarded-For" fwd_header X-Forwarded-For
check "backend receives X-Forwarded-Proto" fwd_header X-Forwarded-Proto

section "Static, health, gzip, logs"
check "/static/logo.txt served from /opt/lab/i08/static" static_ok
check "/static/ has Cache-Control max-age=604800" http_header_has localhost/static/logo.txt '^cache-control:.*max-age=604800'
check "/healthz returns 200 'ok'" health_ok
check "/healthz works even with the backend down" health_local
check "CSS is gzip-compressed" gzip_css
check "requests are logged to /var/log/nginx/i08.access.log" logged

finish
