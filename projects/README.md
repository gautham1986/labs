# Capstone projects

Multi-node projects that combine everything. No auto-grader here: each project has
**acceptance criteria** you verify yourself - writing that verification is part of the job.

Start the fleet: `make fleet` (from the host). You get three boxes on `10.77.0.0/24`:

| host | IP | role |
|---|---|---|
| `lab` | 10.77.0.10 | your workstation / control node |
| `node1` | 10.77.0.11 | target server |
| `node2` | 10.77.0.12 | target server |

Every box has the user `learner` (password `learner`, passwordless sudo). From `lab`:
`ssh-copy-id node1` - and then never type that password again.

Put your code in `workspace/projects/<name>/` and commit it to your own repo - these make
excellent portfolio pieces. Suggested order: P1 -> P2 -> P4 -> P3 -> P6 -> P5.

---

## P1 · Idempotent server bootstrap

Write `bootstrap.sh` that turns a fresh `node1`/`node2` into a production-ready web server when
run from `lab` (`./bootstrap.sh node1`), using only bash + ssh.

**It must configure:** an `ops` admin user with your SSH key and sudo · sshd hardened (keys only,
no root) · nftables default-deny allowing 22/80/9100 · nginx serving a page with the hostname ·
`prometheus-node-exporter` enabled · timezone UTC · a `motd` saying the box is managed.

**Acceptance criteria**
- [ ] Running it twice in a row: the second run changes nothing and says so (print `changed`/`ok` per step).
- [ ] You can still SSH in after it runs (test on node2 first!).
- [ ] `verify.sh node1` checks every item above and exits non-zero on any failure.
- [ ] Fails fast with a clear message if the host is unreachable.

*Then:* rewrite it as an Ansible playbook and compare. What did idempotency cost you in bash?

## P2 · `fleet`: a parallel remote command runner

```
fleet [-g GROUP] [-p PARALLEL] [-t TIMEOUT] -- COMMAND
```
Inventory file (`inventory.ini`-like) with groups. Runs the command on all hosts of a group in
parallel (max `-p` at once), prefixes every output line with the host name, enforces a per-host
timeout, and ends with a summary table (host, exit code, duration). Exit 0 only if all succeeded.

**Acceptance criteria**
- [ ] `fleet -g web -- uptime` on 2 hosts finishes in ~1 round-trip, not 2.
- [ ] A host that's down (stop node2's sshd) shows as FAILED after the timeout, others succeed.
- [ ] Output lines never interleave mid-line.
- [ ] `--dry-run` lists the hosts it would touch.

## P3 · Central logging & alerting

Ship logs from node1/node2 to `lab` (rsyslog over TCP, or `systemd-journal-remote`), store them
per host, rotate them, and run an alerting job every minute that detects bursts of `err`-level
messages and POSTs an alert to a webhook (simulate the receiver with
`python3 -m http.server` or `nc -lk`).

**Acceptance criteria**
- [ ] `logger -p user.err test` on node1 shows up on lab within seconds, tagged with the host.
- [ ] 20 errors in a minute fire exactly **one** alert (dedupe!), not 20.
- [ ] If the log shipper is down, logs are buffered and arrive later (test it).
- [ ] Logs on lab are rotated and compressed.

## P4 · A tiny deploy pipeline

On `lab`: a bare git repo (`/srv/git/app.git`) with a `post-receive` hook. Pushing to `main`
runs tests, builds a release tarball, and performs a **rolling** blue/green deploy (lab e06) to
node1 then node2, behind an nginx load balancer on `lab`.

**Acceptance criteria**
- [ ] `git push` deploys; `curl lab/version` shows the new commit hash.
- [ ] Zero failed requests during a deploy (run a request loop while pushing).
- [ ] A commit that fails tests is rejected and nothing is deployed.
- [ ] A commit that passes tests but fails health checks on node1 never reaches node2.
- [ ] `./rollback.sh` returns to the previous release in < 10 s.

## P5 · Game day

Pair up (or play both roles). The facilitator breaks `node1` with `gameday/chaos.sh` while the
responder handles it as a real incident: declare it, communicate in a channel (a text file is
fine), mitigate, find the root cause, write the postmortem (`templates/postmortem.md`).

```bash
# on node1, as root (facilitator)
sudo /lab/projects/gameday/chaos.sh            # applies one random fault, prints nothing useful
sudo /lab/projects/gameday/chaos.sh --reveal   # what was broken (after the exercise!)
sudo /lab/projects/gameday/chaos.sh --undo     # put it back
```

**Acceptance criteria**
- [ ] Time to detect, time to mitigate and time to resolve recorded for each round.
- [ ] A postmortem per round with at least one *prevent* and one *detect* action item.
- [ ] After 5 rounds, your runbook (`templates/runbook.md`) covers every fault you met.

## P6 · Backup & disaster recovery

Nightly snapshots of node1's `/srv` to node2 over SSH (lab a08 + a restricted SSH key), a
freshness metric for Prometheus (lab e02), and a **restore drill**: destroy node1's data, restore
it, measure it.

**Acceptance criteria**
- [ ] node1's backup key can *only* run the backup (`command=` / `restrict` in `authorized_keys`).
- [ ] `backup_last_success_timestamp_seconds` exposed on node1; an alert rule fires if > 26 h old.
- [ ] Restore drill documented: RPO (how much data could be lost) and RTO (how long it took).
- [ ] Restored data verified with checksums, not by eyeballing.
