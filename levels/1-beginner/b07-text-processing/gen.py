#!/usr/bin/env python3
"""b07 data generator: an nginx access log and a users CSV (random but reproducible per seed)."""
import random, sys
from datetime import datetime, timedelta, timezone

seed, out = int(sys.argv[1]), sys.argv[2]
r = random.Random(seed)

ips = [f"{r.randint(11, 220)}.{r.randint(0, 255)}.{r.randint(0, 255)}.{r.randint(1, 254)}" for _ in range(r.randint(40, 70))]
heavy = r.choice(ips)
paths = ["/", "/index.html", "/login", "/api/products", "/api/cart", "/api/checkout",
         "/static/app.js", "/static/site.css", "/admin", "/healthz", "/api/search"]
bad_path = r.choice(["/api/checkout", "/api/search", "/api/cart"])
statuses = [200] * 75 + [304] * 5 + [301] * 3 + [404] * 8 + [403] * 2 + [401] * 3 + [500] * 3 + [502] * 1
agents = ["Mozilla/5.0 (X11; Linux x86_64)", "curl/8.5.0", "Mozilla/5.0 (Macintosh)", "kube-probe/1.30",
          "python-requests/2.31", "Googlebot/2.1"]
t = datetime(2026, 9, 1, tzinfo=timezone.utc)

with open(f"{out}/access.log", "w") as f:
    for _ in range(r.randint(4000, 6000)):
        t += timedelta(seconds=r.randint(0, 20))
        ip = heavy if r.random() < 0.15 else r.choice(ips)
        status = r.choice(statuses)
        path = bad_path if status == 500 and r.random() < 0.6 else r.choice(paths)
        method = "POST" if path in ("/login", "/api/checkout") else "GET"
        size = 0 if status == 304 else (404 if r.random() < 0.01 else r.randint(120, 90000))
        f.write(f'{ip} - - [{t:%d/%b/%Y:%H:%M:%S} +0000] "{method} {path} HTTP/1.1" {status} {size} "-" "{r.choice(agents)}"\n')

first = ["ana", "ben", "chen", "dara", "eli", "fatima", "gus", "hana", "ivan", "jo", "kofi", "lena", "mo",
         "nia", "omar", "pia", "quinn", "ravi", "sara", "tomas", "uma", "vik", "wen", "xena", "yusuf", "zoe"]
depts = ["platform", "payments", "data", "mobile"]
with open(f"{out}/users.csv", "w") as f:
    f.write("name,email,department,active\n")
    rows = []
    for i, name in enumerate(r.sample(first, len(first))):
        last = r.choice(["smith", "garcia", "ng", "okafor", "kim", "rossi", "patel", "berg"])
        dept, active = ("platform", "yes") if i < 2 else (r.choice(depts), r.choice(["yes", "yes", "no"]))
        rows.append(f"{name.title()} {last.title()},{name}.{last}@example.com,{dept},{active}\n")
    r.shuffle(rows)
    f.writelines(rows)
