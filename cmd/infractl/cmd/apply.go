package cmd

import (
	"context"

	tfrunner "hera/pkg/platform/terraform"

	"github.com/spf13/cobra"
)

var applyCmd = &cobra.Command{
	Use:   "apply [env] [stack] [cloud]",
	Short: "Apply a Terraform stack",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		t, err := resolveTarget(cmd, args)
		if err != nil {
			printError(err.Error())
			return err
		}
		printBanner("Apply")
		printContext(t.Env, t.Stack, t.Cloud, t.Path)
		printBanner("Running terraform apply -auto-approve")
		err = tfrunner.Run(context.Background(), t.Path, tfrunner.ActionApply)
		if err != nil {
			printError(err.Error())
			return err
		}
		printSuccess("Apply completed successfully")
		return nil
	},
}
