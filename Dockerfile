# syntax=docker/dockerfile:1
# Stage 1: build and pack the Go Dag bundle (go-sdk v1.0.0-beta4 requires Go >= 1.25).
FROM golang:1.25 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY cmd ./cmd
RUN CGO_ENABLED=0 go tool airflow-go-pack --output /out/go_hello ./cmd/native

# Stage 2: Airflow 3.4 beta with the packed bundle in the dags folder.
FROM apache/airflow:3.4.0b2-python3.12
COPY --from=build --chown=airflow:root /out/go_hello /opt/airflow/dags/go/go_hello
