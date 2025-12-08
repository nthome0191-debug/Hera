package kubeconfig

import (
	"fmt"
	"os/exec"
	"path/filepath"
	"strings"
)

type ContextMapping struct {
	Env   string
	Cloud string
	Stack string
}

func DetectContext(terraformDir string) (string, error) {
	mapping, err := parseDirectory(terraformDir)
	if err != nil {
		return "", err
	}

	context := mapToContext(mapping)

	if err := verifyContextExists(context); err != nil {
		return "", fmt.Errorf("context '%s' not found in kubeconfig: %w", context, err)
	}

	return context, nil
}

func SwitchContext(context string) error {
	cmd := exec.Command("kubectl", "config", "use-context", context)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to switch context to '%s': %w\nOutput: %s", context, err, string(output))
	}
	return nil
}

func GetCurrentContext() (string, error) {
	cmd := exec.Command("kubectl", "config", "current-context")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("failed to get current context: %w", err)
	}
	return strings.TrimSpace(string(output)), nil
}

func parseDirectory(dir string) (ContextMapping, error) {
	var mapping ContextMapping

	absDir, err := filepath.Abs(dir)
	if err != nil {
		return mapping, err
	}

	parts := strings.Split(absDir, string(filepath.Separator))
	envsIndex := -1
	for i, part := range parts {
		if part == "envs" {
			envsIndex = i
			break
		}
	}

	if envsIndex == -1 || envsIndex+1 >= len(parts) {
		return mapping, fmt.Errorf("could not parse terraform directory: %s", dir)
	}

	mapping.Env = parts[envsIndex+1]

	remaining := parts[envsIndex+2:]
	if len(remaining) == 1 {

		mapping.Stack = remaining[0]
	} else if len(remaining) >= 2 {

		mapping.Cloud = remaining[0]
		mapping.Stack = remaining[1]
	}

	return mapping, nil
}

func mapToContext(mapping ContextMapping) string {
	if mapping.Env == "local" {
		return "hera-local"
	}

	return fmt.Sprintf("hera-%s", mapping.Env)
}

func verifyContextExists(context string) error {
	cmd := exec.Command("kubectl", "config", "get-contexts", "-o", "name")
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("failed to list contexts: %w", err)
	}

	contexts := strings.Split(strings.TrimSpace(string(output)), "\n")
	for _, c := range contexts {
		if strings.TrimSpace(c) == context {
			return nil
		}
	}

	return fmt.Errorf("context not found (available: %s)", strings.Join(contexts, ", "))
}
