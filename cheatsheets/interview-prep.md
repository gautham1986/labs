# Interview prep: Linux for DevOps/SRE

Questions you will be asked, grouped by level, with the lab that teaches the answer. Practice
answering out loud in 2 minutes, then go deeper when the interviewer pushes.

## Fundamentals (b-labs)
- What happens when you type `ls -l` and press enter? (shell parsing, PATH lookup, fork/exec, syscalls) - b08, a06
- Hard link vs symlink? What's an inode? - b02, a01
- Explain `chmod 4755`, `2770`, `1777`. - b04
- How do you find which process is using port 8080? - i05
- `kill` vs `kill -9`? What's a zombie? An orphan? - b06
- What's in `/proc`? Give three useful files. - b06, a04
- How do you find the 10 largest files on a system? - b01

## Operations (i-labs)
- Walk me through writing a systemd unit for a new app. - i01
- How do you look at the logs of a service that failed at 3am? - i02
- cron vs systemd timers - pros and cons? - i03
- A disk was added to a VM - how do you make it usable and persistent? - i04
- What happens when you `curl https://example.com`? (DNS, TCP, TLS, HTTP) - i05, i08
- How do you harden SSH? - i06, e05
- How does a stateful firewall work? - i07
- What does a reverse proxy do? Load balancer algorithms? - i08, e06

## Troubleshooting (a-labs) - expect live scenarios
- The disk is full - walk me through it. Now `du` says it's not full. - a01
- A service won't start after a deploy. - a02
- The server is slow. Where do you start? - a03, cheatsheets/troubleshooting.md
- "Too many open files" - what and how to fix? - a04
- The app can't reach the database. - a05
- How would you debug a program with no useful logs? - a06
- Load average is 20 on a 4-core box but CPU is 10% - why? (I/O wait, D-state) - a03, a06

## SRE (e-labs)
- Define SLI, SLO, SLA and error budget. How would you pick an SLO? - e03
- How do you alert on an SLO without paging on every blip? (burn rates) - e03
- Walk me through an incident you handled. What did the postmortem change? - e01
- What's the difference between monitoring and observability? Golden signals? - e02
- How do containers work under the hood? - e04
- How do you deploy without downtime? How do you roll back? - e06
- Liveness vs readiness probes? Why is restarting not always the fix? - e07
- What toil have you automated, and how did you measure it? - e08, projects

## Scripting (live coding is common)
- Parse a log and print the top 5 IPs. - b07, s07
- Write a script that retries a command with backoff. - s10
- Check a list of URLs in parallel. - s12
- What does `set -euo pipefail` do and where does it fail you? - s01, s09, cheatsheets/bash.md
