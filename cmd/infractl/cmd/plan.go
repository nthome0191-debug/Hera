package cmd

import (
	"github.com/spf13/cobra"

	tf "hera/pkg/platform/terraform"
)

var planCmd = &cobra.Command{
	Use:   "plan <provider> <env> <stack>",
	Short: "Run terraform plan for a given provider/env/stack",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {
		provider := args[0]
		env := args[1]
		stack := args[2]
		return runOperation(tf.OpPlan, provider, env, stack)
	},
}
