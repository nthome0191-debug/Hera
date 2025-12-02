package cmd

import (
	"github.com/spf13/cobra"

	tf "hera/pkg/platform/terraform"
)

var outputCmd = &cobra.Command{
	Use:   "output <provider> <env>",
	Short: "Run terraform output for a given provider/env",
	Args:  cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		provider := args[0]
		env := args[1]
		return runOperation(tf.OpOutput, provider, env, nil)
	},
}
