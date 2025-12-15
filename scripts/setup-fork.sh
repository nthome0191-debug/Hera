#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}                  Infrastructure Project Fork Setup${NC}"
echo -e "${BLUE}==============================================================================${NC}"
echo ""
echo "This script will help you customize this infrastructure project for your"
echo "organization by replacing all 'Hera' references with your project name."
echo ""

# Read current project name from project.yaml if it exists
CURRENT_NAME="hera"
if [ -f "${PROJECT_ROOT}/project.yaml" ]; then
    CURRENT_NAME=$(grep -A1 "^project:" "${PROJECT_ROOT}/project.yaml" | grep "name:" | sed 's/.*name: *"\(.*\)".*/\1/')
fi

# Prompt for new project name
echo -e "${YELLOW}Current project name: ${CURRENT_NAME}${NC}"
read -p "Enter your new project name (lowercase, no spaces): " NEW_PROJECT_NAME

if [ -z "$NEW_PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name cannot be empty${NC}"
    exit 1
fi

# Validate project name (lowercase, alphanumeric, hyphens only)
if [[ ! "$NEW_PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo -e "${RED}Error: Project name must start with a letter and contain only lowercase letters, numbers, and hyphens${NC}"
    exit 1
fi

# Prompt for display name
read -p "Enter your project display name (e.g., 'MyInfra'): " NEW_DISPLAY_NAME
if [ -z "$NEW_DISPLAY_NAME" ]; then
    NEW_DISPLAY_NAME="${NEW_PROJECT_NAME^}" # Capitalize first letter
fi

# Prompt for organization name
read -p "Enter your organization name (for LICENSE): " NEW_ORG_NAME
if [ -z "$NEW_ORG_NAME" ]; then
    NEW_ORG_NAME="${NEW_DISPLAY_NAME} Contributors"
fi

echo ""
echo -e "${BLUE}Summary of changes:${NC}"
echo "  Project name:      ${CURRENT_NAME} → ${NEW_PROJECT_NAME}"
echo "  Display name:      Hera → ${NEW_DISPLAY_NAME}"
echo "  Organization:      Hera Contributors → ${NEW_ORG_NAME}"
echo ""
read -p "Proceed with these changes? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Setup cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Starting setup...${NC}"
echo ""

# Backup project.yaml
if [ -f "${PROJECT_ROOT}/project.yaml" ]; then
    cp "${PROJECT_ROOT}/project.yaml" "${PROJECT_ROOT}/project.yaml.backup"
    echo -e "${GREEN}✓${NC} Backed up project.yaml"
fi

# Update project.yaml
echo -e "${BLUE}[1/8]${NC} Updating project.yaml..."
cat > "${PROJECT_ROOT}/project.yaml" <<EOF
# Project Configuration
# This file defines the core identity of your infrastructure project.
# When forking this project, update these values to match your organization.

project:
  # The name of your infrastructure project (lowercase, no spaces)
  # Used for: Go module name, Terraform resources, Kubernetes groups, etc.
  name: "${NEW_PROJECT_NAME}"

  # Display name for CLI and documentation
  display_name: "${NEW_DISPLAY_NAME}"

  # Organization name for licenses and documentation
  organization: "${NEW_ORG_NAME}"

# Kubernetes RBAC group prefix
# Groups will be named: {project.name}:infra-managers, {project.name}:developers, etc.
kubernetes:
  rbac_group_prefix: "${NEW_PROJECT_NAME}"
  platform_label: "${NEW_PROJECT_NAME}-platform"

# AWS resource naming patterns
aws:
  # Pattern for DynamoDB lock tables: {prefix}-{env}-tf-lock
  dynamodb_table_prefix: "${NEW_PROJECT_NAME}"
  # Pattern for S3 state buckets: {prefix}-{env}-tf-state
  s3_bucket_prefix: "${NEW_PROJECT_NAME}"
EOF
echo -e "${GREEN}✓${NC} Updated project.yaml"

# Update Go module name
echo -e "${BLUE}[2/8]${NC} Updating Go module name in go.mod..."
sed -i.bak "s/^module ${CURRENT_NAME}$/module ${NEW_PROJECT_NAME}/" "${PROJECT_ROOT}/go.mod"
rm -f "${PROJECT_ROOT}/go.mod.bak"
echo -e "${GREEN}✓${NC} Updated go.mod"

# Update all Go import statements
echo -e "${BLUE}[3/8]${NC} Updating Go import statements..."
find "${PROJECT_ROOT}" -name "*.go" -type f -exec sed -i.bak "s|\"${CURRENT_NAME}/|\"${NEW_PROJECT_NAME}/|g" {} \;
find "${PROJECT_ROOT}" -name "*.go.bak" -type f -delete
echo -e "${GREEN}✓${NC} Updated Go imports"

# Update Terraform variables (remove hardcoded defaults to force user configuration)
echo -e "${BLUE}[4/8]${NC} Updating Terraform variable defaults..."
find "${PROJECT_ROOT}/infra/terraform" -name "variables.tf" -type f -exec sed -i.bak \
    "/variable \"project\"/,/^}/s/default[[:space:]]*=[[:space:]]*\"${CURRENT_NAME}\"/default     = \"${NEW_PROJECT_NAME}\"/" {} \;
find "${PROJECT_ROOT}/infra/terraform" -name "variables.tf.bak" -type f -delete
echo -e "${GREEN}✓${NC} Updated Terraform variables"

# Update Terraform tfvars files
echo -e "${BLUE}[5/8]${NC} Updating Terraform tfvars files..."
find "${PROJECT_ROOT}/infra/terraform" -name "*.tfvars" -type f -exec sed -i.bak \
    "s/project[[:space:]]*=[[:space:]]*\"${CURRENT_NAME}\"/project     = \"${NEW_PROJECT_NAME}\"/" {} \;
find "${PROJECT_ROOT}/infra/terraform" -name "*.tfvars" -type f -exec sed -i.bak \
    "s/cluster_name[[:space:]]*=[[:space:]]*\"${CURRENT_NAME}-/cluster_name = \"${NEW_PROJECT_NAME}-/" {} \;
find "${PROJECT_ROOT}/infra/terraform" -name "*.tfvars" -type f -exec sed -i.bak \
    "s/kubeconfig_context_name[[:space:]]*=[[:space:]]*\"${CURRENT_NAME}-/kubeconfig_context_name = \"${NEW_PROJECT_NAME}-/" {} \;
find "${PROJECT_ROOT}/infra/terraform" -name "*.tfvars.bak" -type f -delete
echo -e "${GREEN}✓${NC} Updated tfvars files"

# Update Kubernetes RBAC group names
echo -e "${BLUE}[6/8]${NC} Updating Kubernetes RBAC group names..."
find "${PROJECT_ROOT}/infra/terraform/modules" -name "*.tf" -type f -exec sed -i.bak \
    "s/\"${CURRENT_NAME}:\\([a-z-]*\\)\"/\"${NEW_PROJECT_NAME}:\\1\"/g" {} \;
find "${PROJECT_ROOT}/infra/terraform/modules" -name "*.tf" -type f -exec sed -i.bak \
    "s/'${CURRENT_NAME}:\\([a-z-]*\\)\"/'${NEW_PROJECT_NAME}:\\1\"/g" {} \;
find "${PROJECT_ROOT}/infra/terraform/modules" -name "*.tf.bak" -type f -delete
echo -e "${GREEN}✓${NC} Updated RBAC groups"

# Update Kubernetes labels
echo -e "${BLUE}[7/8]${NC} Updating Kubernetes labels..."
find "${PROJECT_ROOT}" -name "kustomization.yaml" -type f -exec sed -i.bak \
    "s/app.kubernetes.io\\/part-of: ${CURRENT_NAME}-platform/app.kubernetes.io\\/part-of: ${NEW_PROJECT_NAME}-platform/" {} \;
find "${PROJECT_ROOT}" -name "kustomization.yaml.bak" -type f -delete
echo -e "${GREEN}✓${NC} Updated Kubernetes labels"

# Update CLI description
echo -e "${BLUE}[8/8]${NC} Updating CLI description..."
find "${PROJECT_ROOT}" -name "root.go" -type f -exec sed -i.bak \
    "s/Short: \"Hera infrastructure CLI\"/Short: \"${NEW_DISPLAY_NAME} infrastructure CLI\"/" {} \;
find "${PROJECT_ROOT}" -name "root.go.bak" -type f -delete
echo -e "${GREEN}✓${NC} Updated CLI description"

# Update AWS resource patterns in backend examples
echo -e "${BLUE}Updating AWS resource patterns...${NC}"
find "${PROJECT_ROOT}/infra/terraform" -name "backend.tf.example" -type f -exec sed -i.bak \
    "s/${CURRENT_NAME}-/${NEW_PROJECT_NAME}-/g" {} \;
find "${PROJECT_ROOT}/infra/terraform" -name "*.json" -type f -exec sed -i.bak \
    "s/${CURRENT_NAME}-/${NEW_PROJECT_NAME}-/g" {} \;
find "${PROJECT_ROOT}/infra/terraform" -name "*.bak" -type f -delete
echo -e "${GREEN}✓${NC} Updated AWS resource patterns"

# Update operator placeholder comments (optional)
find "${PROJECT_ROOT}/operators" -name "*.go" -type f -exec sed -i.bak \
    "s|github.com/yourorg/${CURRENT_NAME}/|github.com/yourorg/${NEW_PROJECT_NAME}/|g" {} \;
find "${PROJECT_ROOT}/operators" -name "*.go.bak" -type f -delete

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}                            Setup Complete!${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Run 'go mod tidy' to update Go dependencies"
echo "  2. Update README.md with your project details"
echo "  3. Update LICENSE with your organization name"
echo "  4. Review and update any documentation in docs/"
echo "  5. Commit these changes to your repository"
echo ""
echo -e "${YELLOW}Note: Documentation files (README, LICENSE) were not automatically updated.${NC}"
echo -e "${YELLOW}Please review and update them manually with your project details.${NC}"
echo ""
