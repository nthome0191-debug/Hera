package cmd

import (
	"context"

	tfrunner "hera/pkg/platform/terraform"

	"github.com/spf13/cobra"
)

var planCmd = &cobra.Command{
	Use:   "plan [env] [stack] [cloud]",
	Short: "Plan a Terraform stack",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		t, err := resolveTarget(cmd, args)
		if err != nil {
			printError(err.Error())
			return err
		}
		printBanner("Plan")
		printContext(t.Env, t.Stack, t.Cloud, t.Path)
		printBanner("Running terraform plan")
		err = tfrunner.Run(context.Background(), t.Path, tfrunner.ActionPlan)
		if err != nil {
			printError(err.Error())
			return err
		}
		printSuccess("Plan completed")
		return nil
	},
}
