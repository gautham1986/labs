#!/usr/bin/env python3
"""a04 demo service: needs to hold 3000 open files (think: connections) at once."""
import os, resource, time

NEED = 3000
STATUS = "/run/lab-a04/status"
while True:
    fds, soft = [], resource.getrlimit(resource.RLIMIT_NOFILE)[0]
    try:
        for _ in range(NEED):
            fds.append(os.open("/dev/null", os.O_RDONLY))
        status = f"OK: holding {NEED} open files (soft limit {soft})"
        prefix = ""
    except OSError as e:
        status = f"FAILED after {len(fds)} files: {e.strerror} (soft limit {soft})"
        prefix = "<3>"
    finally:
        for fd in fds:
            os.close(fd)
    print(prefix + status, flush=True)
    with open(STATUS + ".tmp", "w") as f:
        f.write(status + "\n")
    os.replace(STATUS + ".tmp", STATUS)
    time.sleep(3)
