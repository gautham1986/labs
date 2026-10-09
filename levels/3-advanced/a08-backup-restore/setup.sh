#!/usr/bin/env bash
# a08 setup: app data worth protecting and a "disaster" button
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd rsync sha256sum
prepare_answers
bash "$LAB_DIR/cleanup.sh"

id appuser >/dev/null 2>&1 || useradd --system --shell /usr/sbin/nologin appuser
D=/srv/a08/data
mkdir -p "$D"/{config,uploads/2026/09,db,"reports Q3"}
echo "env: production" > "$D/config/app.yaml"
echo "listen: 8080" > "$D/config/server.yaml"
head -c 4096 /dev/urandom | base64 > "$D/config/secret.key"
for i in $(seq 1 25); do head -c $((RANDOM % 20000 + 100)) /dev/urandom > "$D/uploads/2026/09/img_$i.jpg"; done
head -c 300K /dev/urandom > "$D/db/app.db"
echo "revenue up" > "$D/reports Q3/summary final (v2).txt"
echo "This is the app data directory." > "$D/README.txt"
ln -s config/app.yaml "$D/current-config"
chown -R appuser:appuser "$D"
chmod 600 "$D/config/secret.key"; chmod 750 "$D/db"

mkdir -p "$LAB_VAR/a08"
(cd "$D" && find . -printf '%y %m %u %g %p %l\n' | sort) > "$LAB_VAR/a08/meta"
(cd "$D" && find . -type f -print0 | sort -z | xargs -0 sha256sum) > "$LAB_VAR/a08/sums"

cat > /usr/local/sbin/a08-disaster <<'DIS'
#!/usr/bin/env bash
# a08 disaster simulator
set -e
[[ $EUID -eq 0 ]] || { echo "run with sudo" >&2; exit 1; }
D=/srv/a08/data
rm -rf "$D/uploads/2026/09/img_1"* "$D/reports Q3"
echo "garbage" > "$D/db/app.db"
chmod 644 "$D/config/secret.key"
rm -f "$D/current-config"
echo "Your files are encrypted. Send 1 BTC." > "$D/README-RANSOM.txt"
touch /var/lib/lab/a08/disaster-ran
echo "💥 disaster happened to $D"
DIS
chmod 755 /usr/local/sbin/a08-disaster
