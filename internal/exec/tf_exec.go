package exec

import (
	"context"
	"hera/internal/resolver"
)

type TerraformAction string

const (
	Plan  TerraformAction = "plan"
	Apply TerraformAction = "apply"

	Destroy TerraformAction = "destroy"
)

func RunTerraform(ctx context.Context, targetModule *resolver.TargetModule, action TerraformAction) error {
	return nil
}
