package cmd

import (
	"context"

	tfrunner "hera/pkg/platform/terraform"

	"github.com/spf13/cobra"
)

var outputCmd = &cobra.Command{
	Use:   "output [env] [stack] [cloud]",
	Short: "Show Terraform outputs",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		t, err := resolveTarget(cmd, args)
		if err != nil {
			printError(err.Error())
			return err
		}
		printBanner("Output")
		printContext(t.Env, t.Stack, t.Cloud, t.Path)
		printBanner("Running terraform output")
		err = tfrunner.Run(context.Background(), t.Path, tfrunner.ActionOutput)
		if err != nil {
			printError(err.Error())
			return err
		}
		printSuccess("Output completed")
		return nil
	},
}
