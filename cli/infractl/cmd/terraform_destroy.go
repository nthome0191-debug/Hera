package cmd

import (
	"hera/internal/exec"
	"hera/internal/resolver"

	"github.com/spf13/cobra"
)

var destroyTm resolver.TargetModule

var destroyCmd = &cobra.Command{
	Use:   "destroy [env] [provider] [stack]",
	Short: "Run terraform destroy for a given target module",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		err := buildTargetModuleFromArgs(args, &destroyTm)
		if err != nil {
			return err
		}
		return exec.RunTerraform(exec.Destroy, &destroyTm)
	},
}

func init() {
	addTerraformFlags(destroyCmd, &destroyTm)
	destroyCmd.ValidArgsFunction = completeModulePath
	rootCmd.AddCommand(destroyCmd)
}
