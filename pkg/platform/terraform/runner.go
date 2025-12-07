package terraform

import (
	"context"
	"os"
	"os/exec"
)

type Action string

const (
	ActionApply   Action = "apply"
	ActionPlan    Action = "plan"
	ActionDestroy Action = "destroy"
	ActionOutput  Action = "output"
)

func Run(ctx context.Context, dir string, action Action) error {
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
