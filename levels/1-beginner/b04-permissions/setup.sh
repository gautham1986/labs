#!/usr/bin/env bash
# b04 setup: a web app tree with sloppy permissions
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd setfacl
prepare_answers

getent group webops >/dev/null || groupadd webops
id webdev >/dev/null 2>&1 || useradd -m -s /bin/bash -G webops webdev

L=/srv/b04
rm -rf "$L"
mkdir -p "$L"/{bin,secrets,uploads,logs,public/{css,js,img/icons}}
printf '#!/usr/bin/env bash\necho deploying...\n' > "$L/bin/deploy.sh"
printf 'DB_USER=app\nDB_PASSWORD=hunter2\n' > "$L/secrets/db.env"
for f in index.html about.html css/site.css js/app.js img/logo.svg img/icons/x.svg; do
  echo "content of $f" > "$L/public/$f"
done
for i in $(seq 1 20); do echo "$(date -u +%FT%TZ) line $i" ; done > "$L/logs/app.log"

# the mess
chmod -R 777 "$L"
chmod 644 "$L/public/css" "$L/public/img/icons"      # broken dirs
chmod 600 "$L/public/js/app.js"                      # unreadable file
chmod 666 "$L/bin/deploy.sh"
chown "$LAB_USER": "$L/bin/deploy.sh"
chmod 755 "$L/secrets"; chmod 644 "$L/secrets/db.env"
chmod 777 "$L/uploads"
chown root:root "$L/logs/app.log"; chmod 640 "$L/logs/app.log"
chmod 755 "$L" "$L/logs"
setfacl -b "$L/logs/app.log"
