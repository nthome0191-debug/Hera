package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var envKey string = "env"

var rootCmd = &cobra.Command{
	Use:   "infractl",
	Short: "Hera infrastructure CLI",
}

func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
}
