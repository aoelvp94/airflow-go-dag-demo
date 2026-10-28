# Pack the Go Dag bundle locally into dist/
pack:
    go tool airflow-go-pack --output dist/go_hello ./cmd/native

vet:
    go vet ./...

build:
    docker compose build

up:
    docker compose up --build

down:
    docker compose down -v

# Trigger the Dag inside the running container
trigger:
    docker compose exec airflow airflow dags trigger go_hello

logs:
    docker compose logs -f airflow
