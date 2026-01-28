package tftest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVpcSetup(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../envs/dev", // Path to your environment
	}

	// Deploy the infra
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	// Get Outputs
	vpcId := terraform.Output(t, opts, "vpc_id")
	region := "us-east-1"

	// 1. Verify Subnet Count
	subnets := aws.GetSubnetsForVpc(t, vpcId, region)
	// If you have 2 clusters, 3 AZs each, Public+Private = 12 subnets
	assert.Equal(t, 12, len(subnets))

	// 2. Verify VPC Endpoints
	// You can use the AWS SDK to list endpoints and check their service names
}
