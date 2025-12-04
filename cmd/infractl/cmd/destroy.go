package cmd

import (
	"context"

	tfrunner "hera/pkg/platform/terraform"

	"github.com/spf13/cobra"
)

var destroyCmd = &cobra.Command{
	Use:   "destroy [env] [stack] [cloud]",
	Short: "Destroy a Terraform stack",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		t, err := resolveTarget(cmd, args)
		if err != nil {
			printError(err.Error())
			return err
		}
		printBanner("Destroy")
		printContext(t.Env, t.Stack, t.Cloud, t.Path)
		printBanner("Running terraform destroy -auto-approve")
		err = tfrunner.Run(context.Background(), t.Path, tfrunner.ActionDestroy)
		if err != nil {
			printError(err.Error())
			return err
		}
		printSuccess("Destroy completed successfully")
		return nil
	},
}
