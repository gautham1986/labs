Debian/Ubuntu layout: configs in `sites-available/`, enabled by symlinking into `sites-enabled/`:
`sudo ln -s /etc/nginx/sites-available/i08.conf /etc/nginx/sites-enabled/` and
`sudo rm /etc/nginx/sites-enabled/default`.
---
```
server {
    listen 80 default_server;
    server_name _;
    access_log /var/log/nginx/i08.access.log;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        ...
    }
}
```
`$remote_addr` is the client IP; `$proxy_add_x_forwarded_for` appends it to any existing XFF header;
`$scheme` is http/https.
---
For `/static/` use `alias /opt/lab/i08/static/;` (note both trailing slashes) and `expires 7d;`.
---
`location = /healthz { return 200 "ok\n"; }` - the `=` makes it an exact match, checked first.
Add `default_type text/plain;` or `add_header Content-Type text/plain;`.
---
gzip: `gzip on;` alone only compresses `text/html`. Add `gzip_types text/css application/javascript application/json text/plain;`.
---
`sudo nginx -t && sudo systemctl enable --now nginx && sudo systemctl reload nginx`
