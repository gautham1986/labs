#!/usr/bin/env bash
# b08 setup: install the team's "labtool"
source "$LAB_ROOT/lib/common.sh"
need_root
prepare_answers
out="OUT-$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"
err="ERR-$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"
mkdir -p /opt/tools/bin /opt/tools/share/labtool
printf '%s\n%s\n' "$out" "$err" > /opt/tools/share/labtool/tokens
chmod 644 /opt/tools/share/labtool/tokens
cat > /opt/tools/bin/labtool <<'TOOL'
#!/usr/bin/env bash
# labtool - prints results to stdout and noise to stderr
{ read -r out; read -r err; } < /opt/tools/share/labtool/tokens
echo "labtool v1.0 - result: $out"
echo "warning: deprecated flag ignored ($err)" >&2
echo "done"
TOOL
chmod 755 /opt/tools/bin/labtool
expect_set b08 out "$(printf 'labtool v1.0 - result: %s\ndone' "$out")"
expect_set b08 err "warning: deprecated flag ignored ($err)"
