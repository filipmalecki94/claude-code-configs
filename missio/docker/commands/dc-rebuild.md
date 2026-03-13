Rebuild a Docker Compose service with proper cache handling.

**Usage:** `/dc-rebuild` followed by service name(s) (e.g., `/dc-rebuild wordpress`, `/dc-rebuild nextjs wordpress`). If no service specified, ask which one.

Steps:

1. Confirm which service(s) to rebuild from `$ARGUMENTS`
2. Check if the service is currently running: `docker compose ps <service>`
3. Determine rebuild strategy:
   - **Default**: `docker compose build <service>` (with cache — fast, handles most changes)
   - **If user reports stale cache or base image update needed**: `docker compose build --no-cache <service>`
4. Run the build command
5. If the service was running, restart it: `docker compose up -d <service>`
6. Verify the rebuilt service is healthy: `docker compose ps <service>`
7. Show the new image ID and creation timestamp

**Important:**
- Never use `--no-cache` unless explicitly requested or cache is confirmed broken
- For nginx: config changes don't need rebuild (bind-mounted), just `docker compose restart nginx`
- After rebuilding wordpress: may need to run `docker compose run --rm wpcli wp cache flush`
- After rebuilding nextjs: wait for the build to complete before declaring success (check logs)
