package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

var (
	flagEnv   string
	flagStack string
	flagCloud string

	repoRoot string
)

var rootCmd = &cobra.Command{
	Use:   "infractl",
	Short: "Hera infrastructure CLI",
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		if repoRoot != "" {
			return nil
		}
		root, err := findRepoRoot()
		if err != nil {
			return err
		}
		repoRoot = root
		return nil
	},
}

func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().StringVar(&flagEnv, "env", "", "environment name")
	rootCmd.PersistentFlags().StringVar(&flagStack, "stack", "", "stack name")
	rootCmd.PersistentFlags().StringVar(&flagCloud, "cloud", "", "cloud provider")
	rootCmd.AddCommand(applyCmd)
	rootCmd.AddCommand(planCmd)
	rootCmd.AddCommand(destroyCmd)
	rootCmd.AddCommand(outputCmd)
	rootCmd.AddCommand(opsCmd)
}

func findRepoRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}
	for {
		p := filepath.Join(dir, "infra", "terraform")
		info, err := os.Stat(p)
		if err == nil && info.IsDir() {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", fmt.Errorf("could not find infra/terraform from %s", dir)
		}
		dir = parent
	}
}

func getRepoRoot() string {
	return repoRoot
}
