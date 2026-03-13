Full reset of Docker Compose environment. THIS IS DESTRUCTIVE — will delete all data including database.

**IMPORTANT:** Before executing, explicitly ask the user for confirmation. List what will be destroyed:
- All containers (stopped and removed)
- All named volumes (MySQL data, WordPress uploads, Redis data)
- All project networks
- Built images (optional)

Steps (only after user confirms):

1. `docker compose down -v --remove-orphans` — stop containers, remove volumes and orphan containers
2. Optionally `docker compose down -v --remove-orphans --rmi local` if user wants images removed too
3. Verify cleanup: `docker compose ps -a` should show nothing
4. `docker volume ls --filter name=$(basename "$PWD")` should show no project volumes
5. Inform user of next steps:
   - Run `docker compose up -d` to start fresh
   - Database will need re-initialization (seed scripts, migrations)
   - WordPress will need re-setup (wp-cli install, plugin activation)
   - Remind about `docker compose run --rm wpcli wp ...` for post-reset setup

**Never run this without explicit user confirmation. This destroys the database.**
