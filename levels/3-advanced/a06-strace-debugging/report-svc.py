#!/usr/bin/env python3
"""a06: a service with deliberately unhelpful error messages."""
import json, os, socket, time

FLAGS = "/var/lib/report-svc/feature-flags.json"
CACHE = ("127.0.0.1", 6380)
STATUS = "/run/report-svc/status"

while True:
    state = "OK: reports are being generated"
    try:
        with open(FLAGS) as f:
            flags = json.load(f)
        if not flags.get("reports_enabled"):
            state = "DEGRADED: reports are disabled"
        else:
            with socket.create_connection(CACHE, timeout=1) as s:
                s.sendall(b"PING\r\n")
                if not s.recv(64).startswith(b"+PONG"):
                    state = "DEGRADED: dependency gave a bad answer"
    except FileNotFoundError:
        state = "DEGRADED: configuration not found"
    except (ValueError, AttributeError):
        state = "DEGRADED: configuration is invalid"
    except OSError:
        state = "DEGRADED: dependency unavailable"
    print(("" if state.startswith("OK") else "<4>") + state, flush=True)
    with open(STATUS + ".tmp", "w") as f:
        f.write(state + "\n")
    os.replace(STATUS + ".tmp", STATUS)
    time.sleep(2)
