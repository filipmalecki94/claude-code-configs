Analyze logs for a Docker Compose service to find errors and issues.

**Usage:** `/dc-logs` followed by a service name (e.g., `/dc-logs wordpress`). If no service specified, check all services.

Steps:

1. Run `docker compose logs --tail=100 $ARGUMENTS` to get recent logs
2. Scan for error patterns:
   - PHP: Fatal error, Warning, uncaught exception, segfault
   - MySQL: ERROR, Access denied, Table doesn't exist, InnoDB corruption
   - Nginx: 502 Bad Gateway, upstream timed out, connect() failed
   - Next.js: Error, ECONNREFUSED, MODULE_NOT_FOUND, build errors
   - Redis: MISCONF, OOM, connection refused
   - General: exit code != 0, killed, OOMKilled, permission denied

3. For each error found, report:
   - **Service**: which container
   - **Error**: the actual error message
   - **Timestamp**: when it occurred
   - **Likely cause**: brief explanation
   - **Fix**: suggested action

4. If no errors found, confirm logs are clean and show last 5 lines as proof.
