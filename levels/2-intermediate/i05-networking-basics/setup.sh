#!/usr/bin/env bash
# i05 setup: two mystery listeners
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd nc ss ip
prepare_answers
bash "$LAB_DIR/cleanup.sh"

port=$((20000 + RANDOM % 10000))
clone_bin nc /opt/lab/i05/bin/mystery-svc
clone_bin nc /opt/lab/i05/bin/legacy-proxy
spawn mystery-svc /opt/lab/i05/bin/mystery-svc -dlk 127.0.0.1 "$port"
spawn legacy-proxy /opt/lab/i05/bin/legacy-proxy -dlk 0.0.0.0 8443
sleep 0.5
ss -Hltn "sport = :$port" | grep -q . || die "mystery-svc failed to start"
expect_set i05 port "$port"
