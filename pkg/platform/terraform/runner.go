package terraform

import (
	"context"
	"fmt"
	"os"
	"os/exec"

	"hera/pkg/platform/kubeconfig"
)

type Action string

const (
	ActionApply   Action = "apply"
	ActionPlan    Action = "plan"
	ActionDestroy Action = "destroy"
	ActionOutput  Action = "output"
)

func Run(ctx context.Context, dir string, action Action) error {
	// Auto-switch kubeconfig context based on environment
	if err := switchKubeconfigContext(dir); err != nil {
		// Log warning but don't fail - some stacks might not need k8s access
		fmt.Fprintf(os.Stderr, "⚠ Warning: Could not switch kubeconfig context: %v\n", err)
	}

	initCmd := exec.CommandContext(ctx, "terraform", "init", "-upgrade")
	initCmd.Stdout = os.Stdout
	initCmd.Stderr = os.Stderr
	initCmd.Stdin = os.Stdin
	initCmd.Dir = dir
	if err := initCmd.Run(); err != nil {
		return err
	}

	var args []string
	switch action {
	case ActionApply:
		args = []string{"apply", "-auto-approve"}
	case ActionDestroy:
		args = []string{"destroy", "-auto-approve"}
	case ActionPlan:
		args = []string{"plan"}
	case ActionOutput:
		args = []string{"output"}
	}

	cmd := exec.CommandContext(ctx, "terraform", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Dir = dir
	return cmd.Run()
}

// switchKubeconfigContext automatically switches to the appropriate kubeconfig context
// based on the terraform directory being operated on
func switchKubeconfigContext(dir string) error {
	// Get current context
	currentContext, err := kubeconfig.GetCurrentContext()
	if err != nil {
		return fmt.Errorf("failed to get current context: %w", err)
	}

	// Detect required context
	requiredContext, err := kubeconfig.DetectContext(dir)
	if err != nil {
		return fmt.Errorf("failed to detect required context: %w", err)
	}

	// Switch if needed
	if currentContext != requiredContext {
		fmt.Fprintf(os.Stderr, "🔄 Switching kubeconfig context: %s → %s\n", currentContext, requiredContext)
		if err := kubeconfig.SwitchContext(requiredContext); err != nil {
			return fmt.Errorf("failed to switch context: %w", err)
		}
		fmt.Fprintf(os.Stderr, "✔ Switched to context: %s\n", requiredContext)
	} else {
		fmt.Fprintf(os.Stderr, "✔ Already using correct context: %s\n", currentContext)
	}

	return nil
}
