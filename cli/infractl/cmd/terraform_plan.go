package cmd

import (
	"hera/internal/exec"
	"hera/internal/resolver"

	"github.com/spf13/cobra"
)

var planTm resolver.TargetModule

var planCmd = &cobra.Command{
	Use:   "plan [env] [provider] [stack]",
	Short: "Run terraform plan for a given target module",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		err := buildTargetModuleFromArgs(args, &planTm)
		if err != nil {
			return err
		}
		return exec.RunTerraform(exec.Plan, &planTm)
	},
}

func init() {
	addTerraformFlags(planCmd, &planTm)
	planCmd.ValidArgsFunction = completeModulePath
	rootCmd.AddCommand(planCmd)
}
