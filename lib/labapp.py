#!/usr/bin/env python3
"""labapp - a tiny, configurable HTTP service used by many labs (standard library only).

Endpoints
  GET /health    200 {"status": "ok", ...}   (503 when --fail-health)
  GET /version   the --version string
  GET /          JSON with service info and the request headers it received
  GET <slow>     sleeps first (see --slow)

Examples
  labapp.py --name inventory --port 8081
  labapp.py --name shop --port 5050 --write /var/lib/shop/cache/warmup.json --slow /products=2
  PORT=7001 labapp.py --version v2 --warmup 3
"""
import argparse
import json
import os
import pwd
import signal
import socket
import sys
import time
from http.server import BaseHTTPRequestHandler, HTTPServer, ThreadingHTTPServer

p = argparse.ArgumentParser(description="tiny lab HTTP service")
p.add_argument("--name", default=os.environ.get("APP_NAME", "labapp"))
p.add_argument("--port", type=int, default=int(os.environ.get("PORT", "8000")))
p.add_argument("--bind", default=os.environ.get("BIND", "0.0.0.0"))
p.add_argument("--version", default=os.environ.get("APP_VERSION", "1.0.0"))
p.add_argument("--config", help="config file that must be readable at startup")
p.add_argument("--write", help="file the app must be able to write at startup (e.g. a cache)")
p.add_argument("--write-bytes", type=int, default=64 * 1024)
p.add_argument("--slow", action="append", default=[], metavar="PATH=SECONDS")
p.add_argument("--warmup", type=float, default=0, help="seconds to wait before listening")
p.add_argument("--fail-health", action="store_true", help="/health returns 503")
p.add_argument("--trigger-dir", help="crash if <dir>/crash exists, hang if <dir>/hang exists")
p.add_argument("--single-thread", action="store_true", help="one request at a time (hangs block everything)")
args = p.parse_args()


def whoami():
    try:
        return pwd.getpwuid(os.getuid()).pw_name
    except KeyError:  # e.g. systemd DynamicUser= without nss-systemd
        return str(os.getuid())


def log(msg):
    print(f"{args.name}[{os.getpid()}]: {msg}", flush=True)


def die(msg):
    # "<3>" = syslog priority "err" when stdout goes to the systemd journal
    print(f"<3>{args.name}[{os.getpid()}]: FATAL: {msg}", flush=True)
    sys.exit(1)


if args.config:
    try:
        with open(args.config) as f:
            f.read()
    except OSError as e:
        die(f"cannot read config {args.config}: {e}")

if args.write:
    try:
        os.makedirs(os.path.dirname(args.write), exist_ok=True)
        with open(args.write, "wb") as f:
            f.write(os.urandom(args.write_bytes))
    except OSError as e:
        die(f"cannot write {args.write}: {e}")

if args.trigger_dir:  # a fresh start clears old triggers
    for t in ("crash", "hang"):
        try:
            os.remove(os.path.join(args.trigger_dir, t))
        except OSError:
            pass

slow = {}
for item in args.slow:
    path, _, secs = item.partition("=")
    slow[path] = float(secs or 1)

if args.warmup:
    log(f"warming up for {args.warmup}s")
    time.sleep(args.warmup)

STARTED = time.time()


class Handler(BaseHTTPRequestHandler):
    server_version = f"{args.name}/{args.version}"

    def _send(self, code, body, ctype="application/json"):
        data = (json.dumps(body, indent=1) + "\n").encode() if not isinstance(body, str) else body.encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if args.trigger_dir:
            if os.path.exists(os.path.join(args.trigger_dir, "crash")):
                log("crash trigger found - exiting")
                os._exit(3)
            if os.path.exists(os.path.join(args.trigger_dir, "hang")):
                log("hang trigger found - hanging forever")
                while True:
                    time.sleep(3600)
        path = self.path.split("?")[0]
        if path in slow:
            time.sleep(slow[path])
        info = {
            "service": args.name,
            "version": args.version,
            "pid": os.getpid(),
            "user": whoami(),
            "host": socket.gethostname(),
            "uptime_s": round(time.time() - STARTED, 1),
        }
        if path == "/health":
            if args.fail_health:
                return self._send(503, {**info, "status": "failing"})
            return self._send(200, {**info, "status": "ok"})
        if path == "/version":
            return self._send(200, args.version + "\n", "text/plain")
        if path in ("/",) or path in slow:
            return self._send(200, {**info, "path": path, "headers": dict(self.headers)})
        return self._send(404, {"error": "not found", "path": path})

    def log_message(self, fmt, *a):
        print(f"{args.name}: {self.address_string()} {fmt % a}", flush=True)


def stop(signum, _frame):
    log(f"received signal {signum}, shutting down")
    sys.exit(0)


signal.signal(signal.SIGTERM, stop)
server_cls = HTTPServer if args.single_thread else ThreadingHTTPServer
server_cls.allow_reuse_address = True
try:
    httpd = server_cls((args.bind, args.port), Handler)
except OSError as e:
    die(f"cannot listen on {args.bind}:{args.port}: {e}")
log(f"version {args.version} listening on {args.bind}:{args.port} as {whoami()}")
httpd.serve_forever()
