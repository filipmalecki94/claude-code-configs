Check the status of all Docker Compose services for this project.

Run the following diagnostic commands and present a clear summary:

1. `docker compose ps -a` — show all containers (running and stopped), their status, and ports
2. `docker compose top` — show running processes (skip if services are down)
3. `docker volume ls --filter name=$(basename "$PWD")` — list project volumes
4. `docker network ls --filter name=$(basename "$PWD")` — list project networks

Present results as a structured summary:
- **Services**: table with name, status (running/stopped/restarting), health, ports
- **Volumes**: list with size if available
- **Networks**: list
- **Issues**: flag any stopped/restarting containers, unhealthy services, or missing expected services

If all services are healthy and running, confirm with a brief "All 7 services running and healthy" style message.
