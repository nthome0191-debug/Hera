package cmd

import (
	"github.com/spf13/cobra"

	tf "hera/pkg/platform/terraform"
)

var planCmd = &cobra.Command{
	Use:   "plan <provider> <env> [stacks...]",
	Short: "Run terraform plan for a given provider/env, optionally targeting specific stacks",
	Args:  cobra.MinimumNArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		provider := args[0]
		env := args[1]
		stacks := []string{}
		if len(args) > 2 {
			stacks = args[2:]
		}
		return runOperation(tf.OpPlan, provider, env, stacks)
	},
}
