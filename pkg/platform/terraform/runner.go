package terraform

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

type Operation string

const (
	OpPlan    Operation = "plan"
	OpApply   Operation = "apply"
	OpDestroy Operation = "destroy"
	OpOutput  Operation = "output"
)

type Options struct {
	RootDir       string
	AutoApprove   bool
	VarFile       string
	BackendConfig []string
}

func Run(op Operation, provider, env, stack string, opts Options) error {
	dir, err := resolvePath(opts.RootDir, provider, env, stack)
	if err != nil {
		return err
	}

	if err := terraformInit(dir, opts); err != nil {
		return fmt.Errorf("terraform init failed: %w", err)
	}

	switch op {
	case OpPlan:
		return terraformPlan(dir, opts)
	case OpApply:
		return terraformApply(dir, opts)
	case OpDestroy:
		return terraformDestroy(dir, opts)
	case OpOutput:
		return terraformOutput(dir, opts)
	default:
		return fmt.Errorf("unsupported operation: %s", op)
	}
}

func resolvePath(rootDir, provider, env, stack string) (string, error) {
	base := filepath.Join(rootDir, "infra", "terraform", "envs", env, provider)
	if stack != "" && stack != "all" {
		base = filepath.Join(base, stack)
	}
	info, err := os.Stat(base)
	if err != nil {
		return "", fmt.Errorf("failed to resolve path %s: %w", base, err)
	}
	if !info.IsDir() {
		return "", fmt.Errorf("path is not a directory: %s", base)
	}
	return base, nil
}

func terraformInit(dir string, opts Options) error {
	args := []string{"init", "-input=false"}
	for _, b := range opts.BackendConfig {
		args = append(args, "-backend-config", b)
	}
	return runTerraform(dir, args...)
}

func terraformPlan(dir string, opts Options) error {
	args := []string{"plan"}
	if opts.VarFile != "" {
		args = append(args, "-var-file", opts.VarFile)
	}
	return runTerraform(dir, args...)
}

func terraformApply(dir string, opts Options) error {
	args := []string{"apply"}
	if opts.AutoApprove {
		args = append(args, "-auto-approve")
	}
	if opts.VarFile != "" {
		args = append(args, "-var-file", opts.VarFile)
	}
	return runTerraform(dir, args...)
}

func terraformDestroy(dir string, opts Options) error {
	args := []string{"destroy"}
	if opts.AutoApprove {
		args = append(args, "-auto-approve")
	}
	if opts.VarFile != "" {
		args = append(args, "-var-file", opts.VarFile)
	}
	return runTerraform(dir, args...)
}

func terraformOutput(dir string, opts Options) error {
	args := []string{"output"}
	return runTerraform(dir, args...)
}

func runTerraform(dir string, args ...string) error {
	cmd := exec.Command("terraform", args...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}
