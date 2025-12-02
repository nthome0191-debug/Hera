package cmd

import (
	"github.com/spf13/cobra"
)

type GlobalConfig struct {
	RootDir       string
	AutoApprove   bool
	VarFile       string
	BackendConfig []string
}

var (
	rootCmd = &cobra.Command{
		Use:   "infractl",
		Short: "Infra control CLI for Hera project",
	}

	globalConfig GlobalConfig

	defaultStacks = []string{
		"network",
		"eks",
		"platform",
	}
)

func Execute() error {
	return rootCmd.Execute()
}

func init() {
	rootCmd.PersistentFlags().StringVar(&globalConfig.RootDir, "root-dir", ".", "Root directory of the Hera repo")
	rootCmd.PersistentFlags().BoolVar(&globalConfig.AutoApprove, "auto-approve", false, "Pass -auto-approve to terraform apply/destroy")
	rootCmd.PersistentFlags().StringVar(&globalConfig.VarFile, "var-file", "", "Path to a terraform .tfvars file")
	rootCmd.PersistentFlags().StringArrayVar(&globalConfig.BackendConfig, "backend-config", nil, "backend config arguments for terraform init")

	// rootCmd.AddCommand(planCmd)
	// rootCmd.AddCommand(applyCmd)
	// rootCmd.AddCommand(destroyCmd)
	// rootCmd.AddCommand(outputCmd)
}
