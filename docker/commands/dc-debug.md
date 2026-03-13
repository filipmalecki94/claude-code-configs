Diagnose a failing or misbehaving Docker Compose service.

**Usage:** `/dc-debug` followed by service name or symptom (e.g., `/dc-debug wordpress`, `/dc-debug 502`).

Follow this diagnostic sequence — stop at the step that reveals the issue:

### 1. Observe
- `docker compose ps -a` — is the service running? restarting? exited?
- Check exit code if stopped: `docker inspect --format='{{.State.ExitCode}}' <container>`

### 2. Logs
- `docker compose logs --tail=50 <service>` — recent errors
- Look for startup failures, crash loops, dependency errors

### 3. Dependencies
- Is the service's dependency healthy? (MySQL for WordPress, WordPress for nginx proxy)
- `docker compose ps mysql` — if MySQL is down, WordPress can't start
- `docker compose exec mysql mysqladmin ping -h localhost` — test MySQL connectivity

### 4. Network
- `docker compose exec <service> ping -c1 <dependency>` — can services reach each other?
- `docker network inspect` on the project network — are all expected services attached?
- For 502 errors: `docker compose exec nginx curl -s http://wordpress:9000` or `http://nextjs:3000`

### 5. Configuration
- `docker compose config --quiet` — validate compose file syntax
- Check `.env` for placeholder values (see `/dc-env-check`)
- Compare running config vs file: `docker compose config` and inspect

### 6. Resources
- `docker stats --no-stream` — memory/CPU usage per container
- `docker system df` — disk usage (full disk = silent failures)
- `df -h /var/lib/docker` — host disk space

### Common Failure Patterns

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| WordPress exit 1 on start | MySQL not ready / wrong DB creds | Check MySQL health, verify DB_* env vars |
| nginx 502 Bad Gateway | Upstream (wordpress/nextjs) not running | Start the upstream service, check its logs |
| nextjs ECONNREFUSED | WP_URL pointing to wrong host | Should be `http://nginx` or `http://wordpress:9000` |
| MySQL "Access denied" | Wrong DB_PASSWORD or user not created | Check .env, recreate user or reset volume |
| Redis connection refused | Redis not started or wrong REDIS_URL | Verify `redis://redis:6379` and redis service status |
| Container restart loop | Crash on startup, check logs | `docker compose logs <service>`, fix root cause |

Present findings clearly with the root cause and recommended fix.
