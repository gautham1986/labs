#!/usr/bin/env python3
"""a07 generator: ~150k JSON log lines for one day, with a few injected problems."""
import json, random, sys
from datetime import datetime, timedelta, timezone

seed, out = int(sys.argv[1]), sys.argv[2]
r = random.Random(seed)
endpoints = ["/api/products", "/api/cart", "/api/checkout", "/api/search", "/api/users/me",
             "/api/recommendations", "/healthz", "/api/orders"]
bad = r.choice(["/api/search", "/api/recommendations", "/api/orders", "/api/cart"])
ips = [f"10.{r.randint(0, 255)}.{r.randint(0, 255)}.{r.randint(1, 254)}" for _ in range(400)]
scraper = f"203.0.113.{r.randint(2, 250)}"
start = datetime(2026, 9, 14, tzinfo=timezone.utc)
spike_min = r.randint(8 * 60, 20 * 60)  # a minute between 08:00 and 20:00
n = r.randint(140_000, 160_000)

def latency(ep):
    base = {"/api/checkout": 180, "/api/search": 90, "/healthz": 2}.get(ep, 40)
    v = r.lognormvariate(0, 0.6) * base
    return int(v * (8 if r.random() < 0.01 else 1))

with open(f"{out}/app.jsonl", "w") as f:
    for i in range(n):
        t = start + timedelta(seconds=86400 * i / n + r.random())
        ep = r.choice(endpoints)
        ip = r.choice(ips)
        p5 = 0.08 if ep == bad else 0.01
        status = 500 if r.random() < p5 else r.choice([200] * 40 + [201, 204, 304, 400, 404])
        if r.random() < 0.004:
            ip, status = scraper, 429
        elif r.random() < 0.0008:
            status = 429
        rec = {"ts": t.strftime("%Y-%m-%dT%H:%M:%S.") + f"{t.microsecond // 1000:03d}Z",
               "level": "error" if status >= 500 else "info", "service": "shop-api",
               "method": "GET", "path": ep, "status": status, "latency_ms": latency(ep),
               "client_ip": ip, "trace_id": f"{r.getrandbits(64):016x}"}
        line = json.dumps(rec, separators=(",", ":"))
        if r.random() < 0.001:
            line = line[: r.randint(10, len(line) - 10)]  # truncated (malformed) line
        f.write(line + "\n")
        # incident: a burst of 503s in one minute
        if int((t - start).total_seconds() // 60) == spike_min and r.random() < 0.9:
            for _ in range(8):
                rec2 = dict(rec, status=503, level="error", path="/api/checkout",
                            latency_ms=r.randint(5000, 9000), trace_id=f"{r.getrandbits(64):016x}")
                f.write(json.dumps(rec2, separators=(",", ":")) + "\n")
