package resolver

import (
	"fmt"
	"os"
	"path/filepath"
)

type TargetModule struct {
	Env      string
	Provider string
	Stack    string
	Path     string // absolute path to tf dir
}

func ResolveModule(tm *TargetModule) error {
	startDir, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("failed to get working directory: %w", err)
	}

	envsRoot, err := FindEnvsRoot(startDir)
	if err != nil {
		return err
	}

	path := filepath.Join(envsRoot, tm.Env, tm.Provider, tm.Stack)
	info, err := os.Stat(path)
	if err != nil {
		return fmt.Errorf("target path %s not found: %w", path, err)
	}
	if !info.IsDir() {
		return fmt.Errorf("target path %s is not a directory", path)
	}

	mainTf := filepath.Join(path, "main.tf")
	if _, err := os.Stat(mainTf); err != nil {
		return fmt.Errorf("main.tf not found in %s: %w", path, err)
	}

	tm.Path = path
	return nil
}

func FindEnvsRoot(start string) (string, error) {
	dir := start
	for {
		envsPath := filepath.Join(dir, "infra", "terraform", "envs")
		if _, err := os.Stat(envsPath); err == nil {
			return envsPath, nil
		}

		parent := filepath.Dir(dir)
		if parent == dir {
			break
		}
		dir = parent
	}
	return "", fmt.Errorf("could not find repo root containing infra/terraform/envs starting from %s", start)
}
