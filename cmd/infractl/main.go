package main

import (
	"log"

	"hera/cmd/infractl/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		log.Fatal(err)
	}
}
