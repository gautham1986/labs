# i08 · Solution

```bash
sudo tee /etc/nginx/sites-available/i08.conf > /dev/null <<'NGINX'
server {
    listen 80 default_server;
    # listen [::]:80 default_server;   # add on hosts with IPv6 (many containers have it disabled)
    server_name _;

    access_log /var/log/nginx/i08.access.log;
    error_log  /var/log/nginx/i08.error.log;

    gzip on;
    gzip_types text/plain text/css application/javascript application/json;
    gzip_min_length 256;

    location = /healthz {
        default_type text/plain;
        return 200 "ok\n";
    }

    location /static/ {
        alias /opt/lab/i08/static/;
        expires 7d;
    }

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 2s;
        proxy_read_timeout 10s;
    }
}
NGINX

sudo ln -sfn /etc/nginx/sites-available/i08.conf /etc/nginx/sites-enabled/i08.conf
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl enable --now nginx
sudo systemctl reload nginx

curl -s localhost/ | head -20
curl -sI localhost/static/logo.txt | grep -i cache-control
curl -s localhost/healthz
```

## Why

- A reverse proxy terminates client connections, so the backend only sees nginx unless you pass
  the original client info in `X-Forwarded-*` headers.
- `alias` replaces the matched location prefix; `root` appends the full URI. With `root` you'd
  need the files under `/opt/lab/i08/static/static/`.
- Exact-match `location =` is evaluated first, so health checks stay cheap and never depend on
  the backend.
- Always `nginx -t` before reload; `reload` keeps serving with the old config if the new one is broken,
  `restart` with a broken config means downtime.
