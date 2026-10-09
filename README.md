# Linux SRE Lab

A hands-on practice environment for **Linux, DevOps and SRE** skills - from your first `ls` to
running incident response on a broken box. Every lab builds a real scenario on a throwaway
Linux machine and **grades your work automatically**.

- **32 system labs** in 4 levels: Beginner -> Intermediate -> Advanced -> Expert
- **12 shell-scripting exercises** with test suites, from arguments to a parallel health checker
- **Capstone projects** on a 3-node fleet, cheatsheets, and postmortem/runbook templates
- One command to drive it all: `lab`

```
$ lab list
Level 1 · Beginner
  ✔ b01  Navigating the filesystem
  ✔ b02  Files, links & archives
  • b03  Users, groups & sudo
  · b04  File permissions, ownership & ACLs
...
$ lab start a01        # builds the scenario: a disk that's full in two different ways
$ lab check a01
  ✔ usage below 50%
  ✘ no deleted files held open on /srv/a01
  ...
```

---

## Quick start

You need **one** of these. Docker is the fastest; a VM is the most realistic.

### Option A - Docker (recommended to start)

Works on Linux, macOS (Docker Desktop / OrbStack / Colima) and Windows (Docker Desktop + WSL2).

```bash
unzip linux-sre-lab.zip && cd linux-sre-lab      # or: git clone <your fork's URL> && cd linux-sre-lab
make up        # builds an Ubuntu 24.04 box with systemd as PID 1 (first build: a few minutes)
make shell     # you're now 'learner' inside the box, with passwordless sudo
lab doctor     # checks the environment
lab start b01
```

To keep it in git (recommended - your solutions in `workspace/` stay out of it via `.gitignore`):

```bash
git init && git add . && git commit -m "Linux SRE lab"
gh repo create linux-sre-lab --private --source . --push     # or add a remote and git push
```

The repo is mounted at `/lab` inside the box, so you can edit files from your host editor.
Your answers and scripts go to `workspace/` (git-ignored). `make down` stops the box; your
home directory survives. `make nuke` deletes everything.

> The container runs **privileged** (systemd, mounts, firewalls and namespaces need it). It's a
> disposable practice box - never reuse these settings for real workloads.

### Option B - a VM (most realistic: real kernel, disks, reboots)

```bash
# Vagrant + VirtualBox (adds two spare disks for the storage lab)
cd env && vagrant up && vagrant ssh

# or Multipass
multipass launch 24.04 --name sre-lab --cpus 2 --memory 2G --disk 15G
multipass mount . sre-lab:/lab
multipass exec sre-lab -- sudo LAB_USER=ubuntu bash /lab/env/bootstrap.sh /lab
multipass shell sre-lab
```

### Option C - any Ubuntu 22.04/24.04 or Debian 12 VM you already have

```bash
sudo ./env/bootstrap.sh       # installs packages, links /lab and the lab command
```
⚠️ Only on a machine you're happy to break. Labs create users, change sshd, firewalls and fstab.

---

## How a lab works

```
lab start i01     # 1. builds the scenario (as root, via sudo)
lab show i01      # 2. read the brief: scenario, tasks, commands to learn
                  # 3. solve it with your own hands in the shell
lab check i01     # 4. automatic grading - green ticks or precise failures
lab hint i01      #    stuck? progressive hints, one at a time
lab solution i01  #    reference solution + the "why" (after you've tried!)
lab reset i01     #    start over;  lab clean i01 removes the scenario
lab progress      # 5. see how far you've come
```

Answers that are values (a port, a PID, a path) go in `~/answers/<lab>-<key>.txt` - the brief
always tells you the exact file. Some answers are randomized per setup, so they can't be copied.

## Curriculum

See **[ROADMAP.md](ROADMAP.md)** for the full plan, the skills each level covers, a suggested
12-week schedule, and "am I ready for the next level?" checklists.

| Level | Labs | Focus |
|---|---|---|
| **1 · Beginner** | b01-b08 | filesystem, files & archives, users, permissions, packages, processes, text processing, shell environment |
| **2 · Intermediate** | i01-i08 | systemd services, journald & logrotate, cron & timers, disks/LVM/fstab, networking, SSH, nftables, nginx |
| **3 · Advanced** | a01-a08 | break/fix: disk full & inodes, failing services, runaway processes, limits & sysctl, network debugging, strace, log analysis at scale, backup & restore |
| **4 · Expert** | e01-e08 | incidents & postmortems, Prometheus metrics, SLOs & error budgets, namespaces & cgroups, security audit, zero-downtime deploys, self-healing, on-call triage tooling |
| **Scripting** | s01-s12 | bash from arguments to traps, getopts, jq and parallel jobs - with test suites |
| **Projects** | P1-P6 | multi-node capstones on `lab` + `node1` + `node2` (`make fleet`) |

## Repository layout

```
.
├── lab                    # the CLI
├── Makefile               # make up / shell / down / fleet / lint / test
├── docker-compose.yml     # the practice box (+ node1/node2 for projects)
├── env/                   # Dockerfile, package list, VM bootstrap, Vagrantfile, cloud-init
├── lib/                   # shared helpers: common.sh, check.sh, labapp.py (tiny HTTP service)
├── levels/
│   ├── 1-beginner/b01-navigation/
│   │   ├── README.md      #   the brief
│   │   ├── setup.sh       #   builds the scenario (idempotent)
│   │   ├── check.sh       #   grades it
│   │   ├── hints.md       #   progressive hints, separated by ---
│   │   ├── solution.md    #   reference solution + explanation
│   │   └── cleanup.sh     #   removes the scenario
│   ├── 2-intermediate/ 3-advanced/ 4-expert/
├── scripting/
│   ├── exercises/s01-arguments/{README.md,starter/,solution/,test.sh}
│   ├── lib/testlib.sh     # the test harness
│   └── templates/script-template.sh
├── projects/              # capstone specs (+ a chaos script for game days)
├── cheatsheets/           # commands, bash, troubleshooting method, interview prep
├── templates/             # postmortem, runbook, learning log
└── workspace/             # YOUR stuff: answers, scripts, notes, progress (git-ignored)
```

## Writing your own labs

Copy any lab directory and edit. The contract:

- `setup.sh` runs as root with `LAB_ROOT`, `LAB_ANSWERS`, `LAB_USER`, `LAB_ID`, `LAB_DIR` set.
  Source `lib/common.sh` for helpers: `need_root`, `need_systemd`, `prepare_answers`,
  `spawn NAME CMD...` (detached background process), `clone_bin` (copy a binary under a new
  process name), `install_app` (tiny HTTP service), `expect_set LAB KEY VALUE` (store an expected
  answer hashed), `remove_unit`, `wait_for`.
- `check.sh` sources `lib/check.sh` and calls `check "description" predicate args...` for each
  item, then `finish`. Predicates include `file_exists`, `mode_is`, `owner_is`, `in_group`,
  `service_active`, `port_listening`, `http_ok`, `http_body_has`, `within`, and
  `check_answer` / `check_answer_is` for answer files.
- Setup must be **idempotent** (call your own `cleanup.sh` first) and leave the box usable.
- Run `make lint` (shellcheck) before committing. For scripting exercises, `make test` verifies
  every reference solution passes and every starter fails.

## Troubleshooting the environment

| Problem | Fix |
|---|---|
| `make up` hangs or systemd won't boot | Needs cgroup v2 + privileged. Docker Desktop: update to a recent version. Linux: `docker info \| grep -i cgroup` should say v2. |
| Can't edit `workspace/` files from the host | `make up` passes your UID into the image; rebuild with `make rebuild` after changing users. |
| `nginx -t`: `[::]:80 failed (97: Address family not supported)` | IPv6 is disabled in the container; don't `listen [::]` (labs handle the default site for you). |
| i04 says device-mapper is unavailable | Your kernel lacks dm (rare). Do the LVM part in a VM. |
| e04 says no cgroup v2 | Use Docker Desktop, a distro from 2021+, or a VM. |
| A lab left the box weird | `lab clean <id>`, or throw the box away: `make nuke && make up`. That's the point of a lab. |

## License

MIT - use it, fork it, teach with it.
