#!/usr/bin/env bash
# b02 setup: a release directory, a config file and a vendor bundle
source "$LAB_ROOT/lib/common.sh"
need_root

L=/opt/lab/b02
rm -rf "$L"
mkdir -p "$L"/{release-1.4.2/{bin,lib,static},config,incoming}
prepare_answers

cat > "$L/release-1.4.2/bin/app" <<'APP'
#!/usr/bin/env bash
echo "app 1.4.2 - hello from $(hostname)"
APP
chmod 750 "$L/release-1.4.2/bin/app"
echo "1.4.2" > "$L/release-1.4.2/VERSION"
for i in 1 2 3; do echo "module $i" > "$L/release-1.4.2/lib/mod$i.sh"; done
echo "<h1>hi</h1>" > "$L/release-1.4.2/static/index.html"
chmod 640 "$L/release-1.4.2/lib/mod2.sh"
# Old timestamps so that "preserve timestamps" is visible
touch -d '2024-03-01 10:00' "$L/release-1.4.2"/{VERSION,bin/app,lib/*,static/*}

printf 'listen_port=8080\nlog_level=info\n' > "$L/config/app.conf"

tmp=$(mktemp -d)
mkdir -p "$tmp/vendor-sdk/docs"
echo "vendor sdk v9" > "$tmp/vendor-sdk/README"
echo "license text" > "$tmp/vendor-sdk/docs/LICENSE"
tar -cJf "$L/incoming/bundle.tar.xz" -C "$tmp" vendor-sdk
rm -rf "$tmp"

chown -R "$LAB_USER": "$L"
