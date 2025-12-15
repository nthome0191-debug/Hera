package cmd

import (
	"hera/internal/exec"
	"hera/internal/resolver"

	"github.com/spf13/cobra"
)

var applyTm resolver.TargetModule

var applyCmd = &cobra.Command{
	Use:   "apply [env] [provider] [stack]",
	Short: "Run terraform apply for a given target module",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		err := buildTargetModuleFromArgs(args, &applyTm)
		if err != nil {
			return err
		}
		return exec.RunTerraform(exec.Apply, &applyTm)
	},
}

func init() {
	addTerraformFlags(applyCmd, &applyTm)
	applyCmd.ValidArgsFunction = completeModulePath
	rootCmd.AddCommand(applyCmd)
}
