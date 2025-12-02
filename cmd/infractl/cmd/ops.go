package cmd

import (
	"fmt"

	tf "hera/pkg/platform/terraform"
)

func runOperation(op tf.Operation, provider, env, stack string) error {
	opts := tf.Options{
		RootDir:       globalConfig.RootDir,
		AutoApprove:   globalConfig.AutoApprove,
		VarFile:       globalConfig.VarFile,
		BackendConfig: globalConfig.BackendConfig,
	}

	if stack == "all" {
		for _, s := range defaultStacks {
			if err := tf.Run(op, provider, env, s, opts); err != nil {
				return fmt.Errorf("%s failed for %s/%s/%s: %w", op, provider, env, s, err)
			}
		}
		return nil
	}

	return tf.Run(op, provider, env, stack, opts)
}
