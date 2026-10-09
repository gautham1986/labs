# e01 · Incident: 502 Bad Gateway

**Level:** Expert · **Time:** ~60 min · **Needs:** systemd, nginx

## Scenario

🚨 **SEV-2** - *"shop.example.com returns 502 for all users"* - 03:12, you're on call.

```
client -> nginx :8088 (site: /etc/nginx/sites-enabled/shop.conf) -> shop.service (python, user shop)
                                                                       └─ cache: /var/lib/shop/cache
```

Nobody changed anything (everybody says). Treat this like a real incident:
**mitigate first, then find root causes, then write it up.** There's more than one fault, and
fixing one changes the symptom.

## Tasks

1. Restore service: `curl -s localhost:8088/` returns **200**, and so does
   `curl -s localhost:8088/products` (that endpoint is legitimately slow: ~2 s).
2. Fix things properly: `shop` must keep running as user `shop`, enabled on boot, and nginx's
   config must pass `nginx -t`. Don't make nginx talk to anything except `shop.service`.
3. Write a blameless **postmortem** to `~/answers/e01-postmortem.md` using
   `templates/postmortem.md` (in this repo). It must include the sections *Summary, Impact,
   Timeline, Root cause, Resolution, Action items* and be at least **150 words**.

## Commands to learn

`curl -sv` `curl -w '%{http_code} %{time_total}\n'` `tail -f /var/log/nginx/error.log`
`systemctl status` `journalctl -u shop -f` `systemctl show -p NRestarts` `ss -tlnp`
`df -h` `df -i` `nginx -T` `proxy_read_timeout` `proxy_connect_timeout`

**502 vs 504:** *Bad Gateway* = nginx couldn't get a valid response (connection refused,
reset, garbage). *Gateway Timeout* = nginx connected but the upstream didn't answer in time.

## Done when

`lab check e01` passes.

## Explore (not graded)

- How would you have **detected** this before users did? Write the alert (symptom-based:
  error rate on the load balancer, not "process down").
- Which of your action items prevent recurrence, and which only improve detection/mitigation?
- Read the Google SRE book chapter "Postmortem Culture: Learning from Failure".
