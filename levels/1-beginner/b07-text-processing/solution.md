# b07 · Solution

```bash
cd /opt/lab/b07

wc -l < access.log > ~/answers/b07-total.txt

awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -1 | awk '{print $2}' > ~/answers/b07-topip.txt

awk '$9 == 404' access.log | wc -l > ~/answers/b07-404.txt

awk '{print $1}' access.log | sort -u | wc -l > ~/answers/b07-uniqueips.txt

awk '$9 == 500 {print $7}' access.log | sort | uniq -c | sort -rn | head -1 | awk '{print $2}' > ~/answers/b07-top500path.txt

awk -F, 'NR > 1 && $3 == "platform" && $4 == "yes" {print $2}' users.csv | sort > ~/answers/b07-platform.txt
```

## Why

- `sort | uniq -c | sort -rn` is the most useful pipeline in operations: frequency counts.
  `uniq` only collapses *adjacent* duplicates, which is why `sort` comes first.
- Grepping for a number matches it anywhere in the line. Match the *field* with awk.
- awk version of question 2 in one process (faster on huge logs):
  `awk '{c[$1]++} END {for (ip in c) if (c[ip] > max) {max = c[ip]; top = ip}; print top}' access.log`
