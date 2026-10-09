Total lines: `wc -l < file` (the `<` avoids printing the filename).
Fields are space-separated: `$1` is the IP, `$9` the status, `$7` the path (count them!).
`awk '{print $9}' access.log | head` is a quick way to confirm you have the right field.
---
The "count and rank" idiom you'll use for the rest of your career:
`awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5`
---
`grep -c 404` also matches sizes, paths, timestamps... Match the status *field* instead:
`awk '$9 == 404' access.log | wc -l`
---
Unique IPs: `awk '{print $1}' access.log | sort -u | wc -l`
Top 500 path: filter with `awk '$9 == 500 {print $7}'`, then the count-and-rank idiom.
---
CSV: `awk -F, '$3 == "platform" && $4 == "yes" {print $2}' users.csv | sort`
Mind the header line - `NR > 1` skips it, though it doesn't match here anyway.
