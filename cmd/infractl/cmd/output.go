package cmd

import (
	"github.com/spf13/cobra"

	tf "hera/pkg/platform/terraform"
)

var outputCmd = &cobra.Command{
	Use:   "output <provider> <env> <stack>",
	Short: "Run terraform output for a given provider/env/stack",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {
		provider := args[0]
		env := args[1]
		stack := args[2]
		return runOperation(tf.OpOutput, provider, env, stack)
	},
}
