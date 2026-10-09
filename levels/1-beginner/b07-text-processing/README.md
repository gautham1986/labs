# b07 · Text processing: grep, cut, sort, uniq, awk

**Level:** Beginner · **Time:** ~40 min · **Needs:** any Linux

## Scenario

Your manager pings you: "the site was flaky yesterday - what happened?" You have the nginx
access log at `/opt/lab/b07/access.log` and a user export at `/opt/lab/b07/users.csv`.
No dashboards, no fancy tools. Just the shell.

Log format (nginx "combined"):
```
IP - - [01/Sep/2026:00:00:01 +0000] "GET /path HTTP/1.1" STATUS BYTES "-" "USER-AGENT"
```

## Tasks

Write each answer to the given file (one value per line):

| # | Question | Answer file |
|---|----------|-------------|
| 1 | Total number of requests in the log | `~/answers/b07-total.txt` |
| 2 | The client IP that made the **most** requests | `~/answers/b07-topip.txt` |
| 3 | Number of responses with status **404** | `~/answers/b07-404.txt` |
| 4 | Number of **unique** client IPs | `~/answers/b07-uniqueips.txt` |
| 5 | The path that returned status **500** most often | `~/answers/b07-top500path.txt` |
| 6 | Emails of **active** users in the **platform** department, sorted A-Z, one per line | `~/answers/b07-platform.txt` |

Careful with question 3: a response *size* can also be 404 bytes...

## Commands to learn

`wc -l` `grep -c / -v / -E / -o` `cut -d' ' -f1` `sort | uniq -c | sort -rn | head`
`awk '{print $1}'` `awk '$9 == 404'` `awk -F,` `sed -n` `head` `tail -f` `less +F` `tr`

## Done when

`lab check b07` passes.

## Explore (not graded)

- Requests per hour: `awk '{print substr($4, 2, 14)}' access.log | uniq -c`
- Which user agents get the most 4xx errors?
- Total bytes served in MB, with one `awk` command.
- Rewrite question 2 as a single `awk` program using an associative array.
- Why is `cat file | grep x` called a "useless use of cat"?
