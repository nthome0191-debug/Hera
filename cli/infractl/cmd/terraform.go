package cmd

import (
	"fmt"

	"hera/internal/resolver"

	"github.com/spf13/cobra"
)

func addTerraformFlags(cmd *cobra.Command, tm *resolver.TargetModule) {
	cmd.Flags().StringVarP(&tm.Env, "env", "e", "", "Environment (e.g. dev, staging, prod, local, bootstrap, global)")
	cmd.Flags().StringVarP(&tm.Provider, "provider", "p", "", "Provider (e.g. aws, azure, gcp, agnostic, kind)")
	cmd.Flags().StringVarP(&tm.Stack, "stack", "s", "", "Stack (e.g. cluster, cluster-access, platform, start-pack, iam-users)")
}

func buildTargetModuleFromArgs(args []string, tm *resolver.TargetModule) error {
	if len(args) != 3 {
		return fmt.Errorf("unexpected num of arguments. Required: [env] [provider] [stack]")
	}

	var env, provider, stack string
	if env == "" && len(args) > 0 {
		env = args[0]
	}
	if provider == "" && len(args) > 1 {
		provider = args[1]
	}
	if stack == "" && len(args) > 2 {
		stack = args[2]
	}

	if env == "" || provider == "" || stack == "" {
		return fmt.Errorf("env, provider and stack must be specified either as positional args or flags")
	}

	tm.Env = env
	tm.Provider = provider
	tm.Stack = stack

	err := resolver.ResolveModule(tm)
	if err != nil {
		return err
	}

	return nil
}
