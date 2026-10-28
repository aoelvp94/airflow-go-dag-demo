# Pack the Go DAG bundle locally into dist/
pack:
    go tool airflow-go-pack --output dist/go_hello ./cmd/native

# Go code quality checks
vet:
    go vet ./...

# Build the Docker image (docker-compose)
build:
    docker compose build

# Start Airflow with docker-compose (legacy method)
up:
    docker compose up --build

# Stop Airflow with docker-compose (legacy method)
down:
    docker compose down -v

# Astro CLI: Start local Airflow environment
astro-start:
    astro dev start

# Astro CLI: Stop local Airflow environment
astro-stop:
    astro dev stop

# Astro CLI: Restart local Airflow environment
astro-restart:
    astro dev restart

# Astro CLI: View logs
astro-logs:
    astro dev logs

# Astro CLI: Run pytest on DAGs
astro-pytest:
    astro dev pytest

# Astro CLI: Access the Airflow CLI
astro-airflow cmd *args:
    astro dev run airflow {{args}}

# Trigger the go_hello DAG (docker-compose)
trigger:
    docker compose exec airflow airflow dags trigger go_hello

# Trigger the go_hello DAG (Astro CLI)
astro-trigger:
    astro dev run airflow dags trigger go_hello

# View container logs (docker-compose)
logs:
    docker compose logs -f airflow
