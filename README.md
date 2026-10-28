# airflow-go-dag-demo

Minimal Airflow 3.4 DAG written **entirely in Go** using the Go Task SDK (AIP-85), packaged as an **Astro CLI project**.

- Go SDK: `github.com/apache/airflow/go-sdk v1.0.0-beta4`
- Airflow: `apache/airflow:3.4.0b2-python3.12` (pre-release — APIs are experimental)
- DAG: `go_hello` (`extract → transform → report`), all tasks on queue `golang`
- Project structure: Astro CLI compatible

## ⚠️ Important: Unofficial Airflow 3.4 Setup

This project uses **`apache/airflow:3.4.0b2-python3.12`** instead of Astro Runtime. 

**Why?** Astro Runtime 3.3 is based on Airflow 3.3.x and does **NOT** include AIP-85 native DAG support required for Go DAGs. This setup is for local development and testing Airflow 3.4 pre-release features with Astro CLI tooling.

**For production:** Wait for Astro Runtime 3.4+ or later, which will include native DAG support.

## How It Works

1. **Go DAG**: `cmd/native/main.go` declares the DAG with `airflow.Dag(...)` and serves it via `airflow.Bundle().Serve()`.
2. **Bundle packing**: `go tool airflow-go-pack` builds a single executable bundle (footer `AFBNDL01`).
3. **Runtime**: The bundle sits in the DAGs folder; the DAG processor runs it to parse the DAG, and the worker runs it for each task.
4. **Coordinator routing**: The `golang` queue is routed to `ExecutableCoordinator`:

```ini
[sdk]
coordinators = {"go": {"classpath": "airflow.sdk.coordinators.executable.ExecutableCoordinator"}}
queue_to_coordinator = {"golang": "go"}
```

This is configured via:
- `AIRFLOW__SDK__*` environment variables in the Dockerfile
- `airflow_settings.yaml` when using `astro dev start`

## Prerequisites

- Go ≥ 1.25
- Docker
- [Astro CLI](https://docs.astronomer.io/astro/cli/install-cli) (`brew install astro` or see installation docs)
- [`just`](https://github.com/casey/just) (optional, for command shortcuts)

## Quick Start with Astro CLI

### Start Airflow locally:

```bash
astro dev start
```

This will:
- Build the Docker image with the Go bundle
- Start Postgres, Airflow scheduler, webserver, and triggerer
- Expose the web UI on http://localhost:8080

Default credentials: `admin` / `admin`

### Trigger the Go DAG:

```bash
astro dev run airflow dags trigger go_hello
```

### View logs:

```bash
astro dev logs
```

### Stop Airflow:

```bash
astro dev stop
```

## Alternative: Using Just Commands

If you have `just` installed, use these convenient shortcuts:

```bash
just astro-start     # Start Airflow with Astro CLI
just astro-trigger   # Trigger go_hello DAG
just astro-logs      # View logs
just astro-stop      # Stop Airflow
```

## Alternative: Docker Compose (Legacy)

The original `docker-compose.yml` is still available:

```bash
just up       # Start with docker-compose
just trigger  # Trigger go_hello
just down     # Stop and clean up
```

## Project Structure

```
airflow-go-dag-demo/
├── .astro/                      # Astro CLI config
│   ├── config.yaml
│   └── dag_integrity_exceptions.txt
├── cmd/native/                  # Go source code
│   └── main.go                  # Go DAG implementation
├── dags/                        # Airflow DAGs folder (bundle copied here)
├── include/                     # Shared resources (Python modules, SQL, etc.)
├── plugins/                     # Custom Airflow plugins
├── tests/                       # DAG tests
├── .dockerignore
├── airflow_settings.yaml        # Airflow config overrides for local dev
├── Dockerfile                   # Multi-stage: builds Go bundle + Airflow image
├── docker-compose.yml           # Legacy standalone setup
├── go.mod / go.sum              # Go dependencies
├── justfile                     # Command shortcuts
├── packages.txt                 # OS packages (apt)
├── requirements.txt             # Python packages (pip)
└── README.md
```

## Building the Go Bundle Locally

To test the Go bundle build without Docker:

```bash
just pack
# Creates: dist/go_hello
```

## Go DAG Details

The `go_hello` DAG has three tasks:

1. **extract**: Returns the number 42
2. **transform**: Takes the number and creates a greeting message
3. **report**: Logs the greeting message

All tasks run on the `golang` queue and are handled by `ExecutableCoordinator`.

## Testing

Run pytest on your DAGs:

```bash
astro dev pytest
# or
just astro-pytest
```

## Notes

- Airflow 3.4 drops Python 3.10; this demo uses Python 3.12.
- Based on the `example/native` DAGs in [apache/airflow `go-sdk`](https://github.com/apache/airflow/tree/main/go-sdk).
- This is a personal demo, not affiliated with the Apache Software Foundation or Astronomer.
- The Dockerfile is unofficial and uses Airflow 3.4 beta instead of Astro Runtime.

## Troubleshooting

### Astro CLI not recognizing the project

Make sure the `.astro/config.yaml` file exists and contains valid YAML.

### Go bundle not found in DAGs folder

The bundle is built during Docker image build. Make sure the build completes successfully:

```bash
astro dev start --force-rebuild
```

### Tasks not running on golang queue

Verify the ExecutableCoordinator configuration in `airflow_settings.yaml` or the Dockerfile environment variables.

## Resources

- [Astro CLI Documentation](https://docs.astronomer.io/astro/cli/overview)
- [Airflow Go SDK](https://github.com/apache/airflow/tree/main/go-sdk)
- [AIP-85: Native DAGs](https://cwiki.apache.org/confluence/display/AIRFLOW/AIP-85+Native+DAGs)

## License

Apache-2.0 — see [LICENSE](LICENSE).
