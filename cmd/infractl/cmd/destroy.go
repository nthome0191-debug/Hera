package cmd

import (
	"github.com/spf13/cobra"

	tf "hera/pkg/platform/terraform"
)

var destroyCmd = &cobra.Command{
	Use:   "destroy <provider> <env> <stack>",
	Short: "Run terraform destroy for a given provider/env/stack",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {
		provider := args[0]
		env := args[1]
		stack := args[2]
		return runOperation(tf.OpDestroy, provider, env, stack)
	},
}
