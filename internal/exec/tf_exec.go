package exec

import (
	"context"
	"fmt"
	"hera/internal/resolver"
	"os"
	osexec "os/exec"
)

type TerraformAction string

const (
	Plan    TerraformAction = "plan"
	Apply   TerraformAction = "apply"
	Destroy TerraformAction = "destroy"
)

func RunTerraform(action TerraformAction, tm *resolver.TargetModule) error {
	if err := runTerraformInit(tm.Path); err != nil {
		return err
	}
	if err := runTerraformValidate(tm.Path); err != nil {
		return err
	}
	switch action {
	case Plan:
		return runTerraform(tm.Path, "plan")
	case Apply:
		return runTerraform(tm.Path, "apply", "-auto-approve")
	case Destroy:
		return runTerraform(tm.Path, "destroy", "-auto-approve")
	default:
		return fmt.Errorf("unsupported action: %s", action)
	}
}

func runTerraformInit(dir string) error {
	return runTerraform(dir, "init", "-upgrade", "-reconfigure")
}

func runTerraformValidate(dir string) error {
	return runTerraform(dir, "validate")
}

func runTerraform(dir string, args ...string) error {
	ctx := context.Background()
	cmd := osexec.CommandContext(ctx, "terraform", args...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("terraform %v failed in %s: %w", args, dir, err)
	}

	return nil
}
