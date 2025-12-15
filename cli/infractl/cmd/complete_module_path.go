package cmd

import (
	"os"
	"path/filepath"
	"strings"

	"hera/internal/resolver"

	"github.com/spf13/cobra"
)

func completeModulePath(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	root, err := resolver.FindEnvsRoot(".")
	if err != nil {
		return nil, cobra.ShellCompDirectiveError
	}

	current := root

	for _, a := range args {
		next := filepath.Join(current, a)
		info, err := os.Stat(next)
		if err != nil || !info.IsDir() {
			return nil, cobra.ShellCompDirectiveNoFileComp
		}
		current = next
	}

	entries, err := os.ReadDir(current)
	if err != nil {
		return nil, cobra.ShellCompDirectiveError
	}

	var res []string
	for _, e := range entries {
		if e.IsDir() && strings.HasPrefix(e.Name(), toComplete) && !strings.HasPrefix(e.Name(), ".") {
			res = append(res, e.Name())
		}
	}

	return res, cobra.ShellCompDirectiveNoFileComp
}
