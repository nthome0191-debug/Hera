package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

const (
	colorReset  = "\033[0m"
	colorGreen  = "\033[32m"
	colorRed    = "\033[31m"
	colorCyan   = "\033[36m"
	colorYellow = "\033[33m"
)

var opsCmd = &cobra.Command{
	Use:   "env",
	Short: "Environment operations",
}

var envListCmd = &cobra.Command{
	Use:   "ls [env]",
	Short: "List environments or stacks in an environment",
	Args:  cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		root := getRepoRoot()
		if root == "" {
			return fmt.Errorf("repository root not detected")
		}
		base := filepath.Join(root, "infra", "terraform", "envs")
		if len(args) == 0 {
			return listEnvs(base)
		}
		return listStacks(base, args[0])
	},
}

func init() {
	opsCmd.AddCommand(envListCmd)
}

func printBanner(title string) {
	fmt.Printf("%s─── Hera :: %s ────────────────────────────────%s\n", colorCyan, title, colorReset)
}

func printContext(env, stack, cloud, path string) {
	fmt.Printf("%sEnvironment:%s %s\n", colorYellow, colorReset, env)
	fmt.Printf("%sStack:%s       %s\n", colorYellow, colorReset, stack)
	if cloud != "" {
		fmt.Printf("%sCloud:%s       %s\n", colorYellow, colorReset, cloud)
	}
	fmt.Printf("%sPath:%s        %s\n", colorYellow, colorReset, path)
	fmt.Println("────────────────────────────────────────────────────")
}

func printSuccess(msg string) {
	fmt.Printf("%s✔ %s%s\n", colorGreen, msg, colorReset)
}

func printError(msg string) {
	fmt.Printf("%s✖ %s%s\n", colorRed, msg, colorReset)
}

func listEnvs(base string) error {
	entries, err := os.ReadDir(base)
	if err != nil {
		return err
	}
	printBanner("Environments")
	for _, e := range entries {
		if e.IsDir() {
			fmt.Println(e.Name())
		}
	}
	return nil
}

func listStacks(base, env string) error {
	envPath := filepath.Join(base, env)
	info, err := os.Stat(envPath)
	if err != nil || !info.IsDir() {
		return fmt.Errorf("environment %s not found", env)
	}
	printBanner("Stacks in " + env)
	entries, err := os.ReadDir(envPath)
	if err != nil {
		return err
	}
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		name := e.Name()
		if name == ".terraform" || len(name) > 0 && name[0] == '.' {
			continue
		}

		subPath := filepath.Join(envPath, name)
		children, err := os.ReadDir(subPath)
		if err != nil {
			fmt.Println(name)
			continue
		}

		printedChild := false
		for _, c := range children {
			if !c.IsDir() {
				continue
			}
			childName := c.Name()
			if childName == ".terraform" || len(childName) > 0 && childName[0] == '.' {
				continue
			}
			fmt.Printf("%s/%s\n", name, childName)
			printedChild = true
		}

		if !printedChild {
			fmt.Println(name)
		}
	}

	return nil
}

type target struct {
	Env   string
	Stack string
	Cloud string
	Path  string
}

func resolveTarget(cmd *cobra.Command, args []string) (target, error) {
	var t target
	if len(args) > 0 {
		t.Env = args[0]
	}
	if len(args) > 1 {
		t.Stack = args[1]
	}
	if len(args) > 2 {
		t.Cloud = args[2]
	}
	if flagEnv != "" {
		t.Env = flagEnv
	}
	if flagStack != "" {
		t.Stack = flagStack
	}
	if flagCloud != "" {
		t.Cloud = flagCloud
	}
	if t.Env == "" || t.Stack == "" {
		return t, fmt.Errorf("env and stack are required")
	}
	root := getRepoRoot()
	if root == "" {
		return t, fmt.Errorf("repository root not detected")
	}
	base := filepath.Join(root, "infra", "terraform", "envs", t.Env)
	var candidate string
	if t.Cloud != "" {
		candidate = filepath.Join(base, t.Cloud, t.Stack)
		info, err := os.Stat(candidate)
		if err == nil && info.IsDir() {
			t.Path = candidate
			return t, nil
		}
	}
	candidate = filepath.Join(base, t.Stack)
	info, err := os.Stat(candidate)
	if err == nil && info.IsDir() {
		t.Path = candidate
		return t, nil
	}
	if t.Cloud == "" {
		return t, fmt.Errorf("could not find stack path for env=%s stack=%s", t.Env, t.Stack)
	}
	return t, fmt.Errorf("could not find stack path for env=%s stack=%s cloud=%s", t.Env, t.Stack, t.Cloud)
}
