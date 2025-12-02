package cmd

import (
	"fmt"
	"os/exec"
	"path/filepath"
	"strings"

	tf "hera/pkg/platform/terraform"
)

type EnvState struct {
	ModulePresent map[string]bool
}

var stackToModule = map[string]string{
	"network": "module.network",
	"eks":     "module.eks_cluster",
	// "platform": "module.platform_base",
}

var stackDeps = map[string][]string{
	"eks": {"network"},
	// "platform": {"eks"},
}

var stackDependents = buildStackDependents(stackDeps)

func buildStackDependents(deps map[string][]string) map[string][]string {
	result := make(map[string][]string)
	for s, parents := range deps {
		for _, p := range parents {
			result[p] = append(result[p], s)
		}
	}
	return result
}

func envDir(rootDir, provider, env string) string {
	return filepath.Join(rootDir, "infra", "terraform", "envs", env, provider)
}

func terraformStateList(dir string) ([]string, error) {
	cmd := exec.Command("terraform", "state", "list", "-no-color")
	cmd.Dir = dir
	out, err := cmd.Output()
	if err != nil {
		return []string{}, nil
	}
	s := strings.TrimSpace(string(out))
	if s == "" {
		return []string{}, nil
	}
	lines := strings.Split(s, "\n")
	return lines, nil
}

func moduleExists(moduleName string, stateList []string) bool {
	if moduleName == "" {
		return false
	}
	prefix := moduleName + "."
	for _, r := range stateList {
		if strings.HasPrefix(r, prefix) {
			return true
		}
	}
	return false
}

func buildEnvState(stateList []string) *EnvState {
	m := make(map[string]bool)
	for stack, module := range stackToModule {
		m[stack] = moduleExists(module, stateList)
	}
	return &EnvState{ModulePresent: m}
}

func ensureBootstrapApplied(rootDir, provider, env string) error {
	if env == "bootstrap" {
		return nil
	}
	bDir := envDir(rootDir, provider, "bootstrap")
	list, err := terraformStateList(bDir)
	if err != nil {
		return fmt.Errorf("failed to inspect bootstrap state: %w", err)
	}
	if len(list) == 0 {
		return fmt.Errorf("bootstrap is not applied for provider %s; run `infractl apply %s bootstrap` first", provider, provider)
	}
	return nil
}

func normalizeStacks(stacks []string) ([]string, error) {
	var result []string
	seen := make(map[string]bool)
	for _, s := range stacks {
		n := strings.ToLower(strings.TrimSpace(s))
		if n == "" {
			continue
		}
		if _, ok := stackToModule[n]; !ok {
			return nil, fmt.Errorf("unknown stack %s", n)
		}
		if !seen[n] {
			seen[n] = true
			result = append(result, n)
		}
	}
	return result, nil
}

func validateApplyDependencies(env string, stacks []string, st *EnvState) error {
	if env == "bootstrap" {
		return nil
	}
	if len(stacks) == 0 {
		return nil
	}
	requested := make(map[string]bool)
	for _, s := range stacks {
		requested[s] = true
	}
	for _, s := range stacks {
		if deps, ok := stackDeps[s]; ok {
			for _, d := range deps {
				if st.ModulePresent[d] {
					continue
				}
				if requested[d] {
					continue
				}
				return fmt.Errorf("stack %s depends on %s, which is not applied; include %s in the command or apply it first", s, d, d)
			}
		}
	}
	return nil
}

func validateDestroyDependencies(env string, stacks []string, st *EnvState) error {
	if env == "bootstrap" {
		return nil
	}
	if len(stacks) == 0 {
		return nil
	}
	requested := make(map[string]bool)
	for _, s := range stacks {
		requested[s] = true
	}
	for _, s := range stacks {
		if dependents, ok := stackDependents[s]; ok {
			for _, d := range dependents {
				if st.ModulePresent[d] && !requested[d] {
					return fmt.Errorf("cannot destroy stack %s because dependent stack %s is still applied; destroy %s first or include it in the same command", s, d, d)
				}
			}
		}
	}
	return nil
}

func buildTargets(stacks []string) []string {
	var targets []string
	for _, s := range stacks {
		if m, ok := stackToModule[s]; ok && m != "" {
			targets = append(targets, m)
		}
	}
	return targets
}

func runOperation(op tf.Operation, provider, env string, stacks []string) error {
	ns, err := normalizeStacks(stacks)
	if err != nil {
		return err
	}

	if err := ensureBootstrapApplied(globalConfig.RootDir, provider, env); err != nil {
		return err
	}

	dir := envDir(globalConfig.RootDir, provider, env)
	stateList, err := terraformStateList(dir)
	if err != nil {
		return err
	}
	envState := buildEnvState(stateList)

	if op == tf.OpApply {
		if err := validateApplyDependencies(env, ns, envState); err != nil {
			return err
		}
	}

	if op == tf.OpDestroy {
		if err := validateDestroyDependencies(env, ns, envState); err != nil {
			return err
		}
	}

	targets := buildTargets(ns)

	opts := tf.Options{
		RootDir:       globalConfig.RootDir,
		AutoApprove:   globalConfig.AutoApprove,
		VarFile:       globalConfig.VarFile,
		BackendConfig: globalConfig.BackendConfig,
		Targets:       targets,
	}

	if err := tf.Run(op, provider, env, opts); err != nil {
		return fmt.Errorf("%s failed for %s/%s: %w", op, provider, env, err)
	}

	return nil
}
