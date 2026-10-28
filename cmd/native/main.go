// Package main is a minimal Airflow Dag written entirely in Go (AIP-85).
//
// The Dag processor runs the packed binary to parse the Dag, and the worker runs it again
// for each task. Pack it with:
//
//	go tool airflow-go-pack --output dist/go_hello ./cmd/native
package main

import (
	"fmt"
	"log"

	"github.com/apache/airflow/go-sdk/airflow"
)

type greeting struct {
	Message string `json:"message"`
	Rows    int    `json:"rows"`
}

func extract(airflow.Context) (int, error) {
	return 42, nil
}

func transform(_ airflow.Context, rows int) (greeting, error) {
	return greeting{Message: fmt.Sprintf("hello from Go, %d rows", rows), Rows: rows}, nil
}

func report(actx airflow.Context, g greeting) error {
	actx.Logger().InfoContext(actx, "go task finished", "message", g.Message, "rows", g.Rows)
	return nil
}

func newHelloDag() *airflow.DagRef {
	dag := airflow.Dag("go_hello", airflow.DagSpec{
		Schedule: "@daily",
		Queue:    "golang",
		Tags:     []string{"go", "native", "demo"},
	})

	extracted := dag.Task(extract)
	transformed := dag.Task(transform, airflow.Inputs(extracted))
	dag.Task(report, airflow.Inputs(transformed))

	return dag
}

func main() {
	bundle := airflow.Bundle()
	bundle.Register(newHelloDag())
	if err := bundle.Serve(); err != nil {
		log.Fatal(err)
	}
}
