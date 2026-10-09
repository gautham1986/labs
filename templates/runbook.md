# Runbook: <service / alert name>

**Owner:** · **Last reviewed:** YYYY-MM-DD · **Dashboards:** · **Related alerts:**

## What this service does
<!-- One paragraph. Who depends on it? What breaks for users when it's down? -->

## Symptoms
<!-- What the alert says, what users see, which graphs move. -->

## Checks
<!-- Numbered, copy-pasteable commands, each with "what good looks like". -->
1. `systemctl status <svc>` - expect `active (running)`
2. `curl -s localhost:<port>/health` - expect `200`
3. ...

## Fix
<!-- Known failure modes and their remediation, most common first. Safe actions first. -->
### Case A: ...
### Case B: ...

## Escalation
<!-- When to escalate (thresholds, time limits), to whom, with what information. -->

## History
<!-- Links to past incidents/postmortems involving this runbook. -->
