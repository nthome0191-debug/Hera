package kubeconfig

import (
	"fmt"
	"os/exec"
	"path/filepath"
	"strings"
)

// ContextMapping defines how to map environment paths to kubeconfig contexts
type ContextMapping struct {
	Env   string
	Cloud string
	Stack string
}

// DetectContext determines the appropriate kubeconfig context based on the terraform directory
func DetectContext(terraformDir string) (string, error) {
	// Parse the terraform directory to extract env, cloud, stack
	mapping, err := parseDirectory(terraformDir)
	if err != nil {
		return "", err
	}

	// Map to kubeconfig context name
	context := mapToContext(mapping)

	// Verify the context exists
	if err := verifyContextExists(context); err != nil {
		return "", fmt.Errorf("context '%s' not found in kubeconfig: %w", context, err)
	}

	return context, nil
}

// SwitchContext switches to the specified kubeconfig context
func SwitchContext(context string) error {
	cmd := exec.Command("kubectl", "config", "use-context", context)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to switch context to '%s': %w\nOutput: %s", context, err, string(output))
	}
	return nil
}

// GetCurrentContext returns the current kubeconfig context
func GetCurrentContext() (string, error) {
	cmd := exec.Command("kubectl", "config", "current-context")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("failed to get current context: %w", err)
	}
	return strings.TrimSpace(string(output)), nil
}

// parseDirectory extracts environment, cloud, and stack from terraform directory path
// Examples:
//   - /path/to/infra/terraform/envs/local/platform -> {Env: "local", Cloud: "", Stack: "platform"}
//   - /path/to/infra/terraform/envs/dev/aws/cluster -> {Env: "dev", Cloud: "aws", Stack: "cluster"}
func parseDirectory(dir string) (ContextMapping, error) {
	var mapping ContextMapping

	// Normalize path
	absDir, err := filepath.Abs(dir)
	if err != nil {
		return mapping, err
	}

	// Find the "envs" directory
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

	// Extract environment (always follows "envs")
	mapping.Env = parts[envsIndex+1]

	// Check if there's a cloud provider directory
	remaining := parts[envsIndex+2:]
	if len(remaining) == 1 {
		// Pattern: envs/{env}/{stack}
		mapping.Stack = remaining[0]
	} else if len(remaining) >= 2 {
		// Pattern: envs/{env}/{cloud}/{stack}
		mapping.Cloud = remaining[0]
		mapping.Stack = remaining[1]
	}

	return mapping, nil
}

// mapToContext maps a ContextMapping to a kubeconfig context name
// Naming convention:
//   - local environments: kind-hera-local
//   - cloud environments: hera-{env}
func mapToContext(mapping ContextMapping) string {
	// Local environment
	if mapping.Env == "local" {
		return "kind-hera-local"
	}

	// All other environments follow: hera-{env}
	// Examples: hera-dev, hera-staging, hera-prod, hera-playground
	return fmt.Sprintf("hera-%s", mapping.Env)
}

// verifyContextExists checks if a context exists in kubeconfig
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
