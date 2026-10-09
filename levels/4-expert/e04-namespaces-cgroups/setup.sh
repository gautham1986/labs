#!/usr/bin/env bash
# e04 setup: tools for the cgroup/namespace exercises
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd unshare nsenter python3
prepare_answers
bash "$LAB_DIR/cleanup.sh"

[[ -f /sys/fs/cgroup/cgroup.controllers ]] || die "this host doesn't use cgroup v2 (unified hierarchy). Use Docker Desktop, a recent distro, or a VM."
mkdir -p /opt/lab/e04/bin
clone_bin sleep /opt/lab/e04/bin/jail-sleep
cat > /opt/lab/e04/bin/memhog <<'PY'
#!/usr/bin/env python3
# memhog - allocate (and touch) 1 MiB at a time until something stops us
import time
chunks = []
while True:
    chunks.append(bytearray(b"x" * 1048576))
    if len(chunks) % 8 == 0:
        print(f"memhog: {len(chunks)} MiB allocated", flush=True)
    time.sleep(0.01)
PY
chmod 755 /opt/lab/e04/bin/memhog
info "Available controllers: $(cat /sys/fs/cgroup/cgroup.controllers)"
