# syntax=docker/dockerfile:1
# =============================================================================
# UNOFFICIAL Airflow 3.4.0b2 Image for Astro CLI
# =============================================================================
# This Dockerfile uses apache/airflow:3.4.0b2-python3.12 instead of the
# official Astro Runtime. Astro Runtime 3.3 is based on Airflow 3.3.x and
# does NOT include AIP-85 native DAG support required for Go DAGs.
#
# Use this setup for testing Airflow 3.4 pre-release features locally with
# Astro CLI tooling. For production, wait for Astro Runtime 3.4+ or later.
# =============================================================================

# Stage 1: Build and pack the Go DAG bundle (go-sdk v1.0.0-beta4 requires Go >= 1.25)
FROM golang:1.25 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY cmd ./cmd
RUN CGO_ENABLED=0 go tool airflow-go-pack --output /out/go_hello ./cmd/native

# Stage 2: Airflow 3.4 beta with Astro CLI-compatible layout
FROM apache/airflow:3.4.0b2-python3.12

# Set Airflow home (matches Astro conventions)
ENV AIRFLOW_HOME=/usr/local/airflow

# Copy the packed Go bundle into the dags folder
COPY --from=build --chown=airflow:root /out/go_hello ${AIRFLOW_HOME}/dags/go/go_hello

# Install OS-level packages from packages.txt
COPY packages.txt .
USER root
RUN if [ -s packages.txt ]; then \
    apt-get update && \
    cat packages.txt | grep -v '^#' | xargs -r apt-get install -y --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; \
    fi
USER airflow

# Install Python packages from requirements.txt (if needed for future Python DAGs)
COPY requirements.txt .
RUN if [ -s requirements.txt ]; then \
    pip install --no-cache-dir -r requirements.txt; \
    fi

# Configure ExecutableCoordinator for native Go DAGs via environment variables
# These can be overridden by airflow_settings.yaml when using `astro dev start`
ENV AIRFLOW__SDK__COORDINATORS='{"go": {"classpath": "airflow.sdk.coordinators.executable.ExecutableCoordinator"}}'
ENV AIRFLOW__SDK__QUEUE_TO_COORDINATOR='{"golang": "go"}'
