# Linux SRE Lab - environment shortcuts
#   make up      build + start the practice box
#   make shell   open a shell in it as 'learner'
#   make root    open a root shell in it
#   make fleet   also start node1 + node2 (multi-host projects)
#   make down    stop everything (your home dir is kept)
#   make nuke    stop and delete everything, including your home dir volume
#   make lint    shellcheck every script in the repo
#   make test    self-test the scripting track (reference solutions must pass)

SHELL := /bin/bash
COMPOSE ?= docker compose

UID_ := $(shell id -u)
GID_ := $(shell id -g)
export LAB_UID := $(if $(filter 0,$(UID_)),1000,$(UID_))
export LAB_GID := $(if $(filter 0,$(GID_)),1000,$(GID_))

.PHONY: help up shell root fleet down nuke rebuild logs lint test

help:
	@sed -n '2,10s/^# \{0,1\}//p' Makefile

up:
	@mkdir -p workspace
	$(COMPOSE) up -d --build lab
	@echo "Waiting for systemd to boot..."; \
	for i in $$(seq 1 30); do \
	  state=$$($(COMPOSE) exec -T lab systemctl is-system-running 2>/dev/null); \
	  case "$$state" in running|degraded) break;; esac; sleep 1; \
	done; echo "System state: $$state"
	@echo "Ready. Run: make shell"

shell:
	$(COMPOSE) exec -u learner -w /home/learner lab bash -l

root:
	$(COMPOSE) exec lab bash -l

fleet:
	$(COMPOSE) --profile fleet up -d --build

down:
	$(COMPOSE) --profile fleet down

nuke:
	$(COMPOSE) --profile fleet down -v --rmi local

rebuild:
	$(COMPOSE) build --no-cache lab

logs:
	$(COMPOSE) logs -f lab

lint:
	@command -v shellcheck >/dev/null || { echo "install shellcheck first"; exit 1; }
	@files=$$( { echo lab; find lib env levels scripting projects templates -type f \( -name '*.sh' -o -name '*.bash' \); } \
	          | grep -v '/starter/' | sort); \
	 shellcheck -x -S warning $$files && echo "shellcheck: $$(echo $$files | wc -w) files clean"

test:
	@bash scripting/selftest.sh
