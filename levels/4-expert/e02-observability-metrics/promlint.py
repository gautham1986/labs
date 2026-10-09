#!/usr/bin/env python3
"""Minimal Prometheus text exposition format validator. Prints problems, exits 1 if any."""
import re, sys

NAME = r"[a-zA-Z_:][a-zA-Z0-9_:]*"
SAMPLE = re.compile(rf'^({NAME})(\{{(?:\s*[a-zA-Z_][a-zA-Z0-9_]*="(?:[^"\\]|\\.)*"\s*,?)*\}})?\s+(\S+)(\s+-?\d+)?$')
helps, types, samples, problems = set(), {}, [], []
for n, line in enumerate(open(sys.argv[1]), 1):
    line = line.rstrip("\n")
    if not line.strip():
        continue
    if line.startswith("# HELP "):
        helps.add(line.split()[2])
    elif line.startswith("# TYPE "):
        parts = line.split()
        if len(parts) != 4 or parts[3] not in ("counter", "gauge", "histogram", "summary", "untyped"):
            problems.append(f"line {n}: bad TYPE line: {line}")
        else:
            types[parts[2]] = parts[3]
    elif line.startswith("#"):
        continue
    else:
        m = SAMPLE.match(line)
        if not m:
            problems.append(f"line {n}: not a valid sample: {line}")
            continue
        try:
            float(m.group(3))
        except ValueError:
            problems.append(f"line {n}: value is not a number: {m.group(3)}")
        samples.append(m.group(1))
for name in sorted(set(samples)):
    if name not in helps:
        problems.append(f"{name}: missing # HELP")
    if name not in types:
        problems.append(f"{name}: missing # TYPE")
print("\n".join(problems) if problems else f"ok: {len(samples)} samples")
sys.exit(1 if problems else 0)
