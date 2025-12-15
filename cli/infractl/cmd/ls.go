package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"hera/internal/resolver"
	"hera/internal/utils/print"

	"github.com/spf13/cobra"
)

var lsTree bool

var lsCmd = &cobra.Command{
	Use:   "ls [path...]",
	Short: "Discover environments, providers, and modules",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		if lsTree {
			return walkTree(args)
		}
		return walkAndList(args)
	},
}

func init() {
	lsCmd.ValidArgsFunction = completeModulePath
	lsCmd.Flags().BoolVar(&lsTree, "tree", false, "Show directory tree")
	rootCmd.AddCommand(lsCmd)
}

func walkAndList(parts []string) error {
	root, err := resolver.FindEnvsRoot(".")
	if err != nil {
		return err
	}

	current := root

	for _, p := range parts {
		next := filepath.Join(current, p)
		info, err := os.Stat(next)
		if err != nil || !info.IsDir() {
			return fmt.Errorf("path does not exist: %s", next)
		}
		current = next
	}

	entries, err := os.ReadDir(current)
	if err != nil {
		return err
	}

	for _, e := range entries {
		if e.IsDir() && !strings.HasPrefix(e.Name(), ".") {
			fmt.Println(e.Name())
		}
	}
	return nil
}

func walkTree(parts []string) error {
	root, err := resolver.FindEnvsRoot(".")
	if err != nil {
		return err
	}

	current := root
	for _, p := range parts {
		next := filepath.Join(current, p)
		info, err := os.Stat(next)
		if err != nil || !info.IsDir() {
			return fmt.Errorf("path does not exist: %s", filepath.Join(parts...))
		}
		current = next
	}

	fmt.Println(filepath.Base(current))
	return print.Tree(current, "")
}
