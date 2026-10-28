# airflow-go-dag-demo

Minimal Airflow 3.4 Dag written **entirely in Go** using the Go Task SDK (AIP-85).

- Go SDK: `github.com/apache/airflow/go-sdk v1.0.0-beta4`
- Airflow: `apache/airflow:3.4.0b2-python3.12` (pre-release — APIs are experimental)
- Dag: `go_hello` (`extract → transform → report`), all tasks on queue `golang`

## How it works

1. `cmd/native/main.go` declares the Dag with `airflow.Dag(...)` and serves it via `airflow.Bundle().Serve()`.
2. `go tool airflow-go-pack` builds a single executable bundle (footer `AFBNDL01`).
3. The bundle sits in the Dags folder; the Dag processor runs it to parse the Dag, and the worker runs it for each task.
4. The `golang` queue is routed to `ExecutableCoordinator`:

```ini
[sdk]
coordinators = {"go": {"classpath": "airflow.sdk.coordinators.executable.ExecutableCoordinator"}}
queue_to_coordinator = {"golang": "go"}
```

(`docker-compose.yml` sets these as `AIRFLOW__SDK__*` env vars.)

## Run

Requires Go ≥ 1.25, Docker and [`just`](https://github.com/casey/just).

```bash
just pack     # local bundle in dist/go_hello
just up       # Postgres + Airflow standalone on http://localhost:8080
just trigger  # trigger go_hello
```

`airflow standalone` prints the admin password in the container logs.

## Notes

- Airflow 3.4 drops Python 3.10; this demo uses Python 3.12.
- Based on the `example/native` Dags in [apache/airflow `go-sdk`](https://github.com/apache/airflow/tree/main/go-sdk).
- Personal demo, not affiliated with the Apache Software Foundation.

## License

Apache-2.0 — see [LICENSE](LICENSE).
