#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=healthcheck.sh
S_TIMEOUT=20
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks

# --- test servers: a working HTTP server, a "black hole" that accepts and never answers ---
free_port() { python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])'; }
HTTP_PORT=$(free_port); HANG_PORT=$(free_port); CLOSED_PORT=$(free_port)
mkdir -p "$TMPD/www/health"; echo ok > "$TMPD/www/health/index.html"
python3 -m http.server "$HTTP_PORT" --bind 127.0.0.1 --directory "$TMPD/www" >/dev/null 2>&1 & P1=$!
python3 -c "
import socket, time
s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('127.0.0.1', $HANG_PORT)); s.listen(50); conns = []
while True:
    c, _ = s.accept(); conns.append(c)
" >/dev/null 2>&1 & P2=$!
trap 'kill $P1 $P2 2>/dev/null; rm -rf "$TMPD"' EXIT
for _ in $(seq 50); do curl -s -o /dev/null "127.0.0.1:$HTTP_PORT/" && break; sleep 0.1; done

cat > "$TMPD/mixed.txt" <<CFG
# checks
http http://127.0.0.1:$HTTP_PORT/health/

tcp  127.0.0.1:$HTTP_PORT
http http://127.0.0.1:$HTTP_PORT/nope
tcp  127.0.0.1:$CLOSED_PORT
ping 127.0.0.1
CFG
printf 'http http://127.0.0.1:%s/\n' "$HANG_PORT" "$HANG_PORT" "$HANG_PORT" "$HANG_PORT" > "$TMPD/hang.txt"
printf 'tcp 127.0.0.1:%s\n' "$HTTP_PORT" > "$TMPD/good.txt"
elapsed() { local s; s=$(date +%s.%N); "$@" >/dev/null 2>&1; awk -v s="$s" -v e="$(date +%s.%N)" 'BEGIN { printf "%.2f", e - s }'; }

section "Checks"
t "all good -> 'OK' line, exit 0"         '[[ "$(S good.txt)" == "OK   tcp 127.0.0.1:$HTTP_PORT" ]]'
t "one line per check, in file order, comments/blanks skipped" '[[ $(S mixed.txt | wc -l) -eq 5 ]] && S mixed.txt | awk "{print \$2}" | tr "\n" " " | grep -qx "http tcp http tcp ping "'
t "http 200 -> OK"                        'S mixed.txt | sed -n 1p | grep -q "^OK   http http://127.0.0.1:$HTTP_PORT/health/$"'
t "http 404 -> FAIL"                      'S mixed.txt | sed -n 3p | grep -q "^FAIL http "'
t "closed tcp port -> FAIL"               'S mixed.txt | sed -n 4p | grep -q "^FAIL tcp 127.0.0.1:$CLOSED_PORT"'
t "unknown type -> FAIL (unknown check type)" 'S mixed.txt | sed -n 5p | grep -q "^FAIL ping .*unknown check type"'
t "any failure -> exit 1"                 'S mixed.txt >/dev/null; [[ $? -eq 1 ]]'

section "Timeouts & parallelism"
t "hanging server times out (-t 1) -> FAIL"  'S -t 1 hang.txt | grep -c "^FAIL" | grep -qx 4'
t "4 hanging checks with -t 1 finish in < 2.5s (parallel!)" 'e=$(elapsed S -t 1 hang.txt); awk -v e="$e" "BEGIN { exit !(e < 2.5) }"'

section "JSON"
t "-j prints a valid JSON array"         'S -j mixed.txt | jq -e "type == \"array\" and length == 5"'
t "-j keeps order and booleans"          '[[ "$(S -j mixed.txt | jq -c "[.[].ok]")" == "[true,true,false,false,false]" ]]'
t "-j objects have type/target/ok"       'S -j good.txt | jq -e ".[0] == {\"type\":\"tcp\",\"target\":\"127.0.0.1:$HTTP_PORT\",\"ok\":true}"'

section "Errors"
t "no file -> exit 2"        'S >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "missing file -> exit 2"   'S nope.txt >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "-t 0 -> exit 2"           'S -t 0 good.txt >/dev/null 2>&1; [[ $? -eq 2 ]]'
done_testing
