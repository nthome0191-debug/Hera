# Hera Platform Makefile
# TODO: Implement build targets for the entire platform

.PHONY: help
help: ## Display this help message
	@echo "Hera Platform Build System"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

##@ Development

.PHONY: init
init: ## Initialize development environment
	@echo "TODO: Initialize development environment"
	# @terraform -chdir=infra/terraform/envs/dev/aws init
	# @go mod download

.PHONY: fmt
fmt: ## Format code (Terraform and Go)
	@echo "TODO: Format Terraform files"
	# @terraform fmt -recursive infra/
	@echo "TODO: Format Go files"
	# @go fmt ./...

.PHONY: lint
lint: ## Lint code (Terraform and Go)
	@echo "TODO: Lint Terraform files"
	# @terraform fmt -check -recursive infra/
	# @tflint infra/terraform/modules/...
	@echo "TODO: Lint Go files"
	# @golangci-lint run ./...

.PHONY: validate
validate: ## Validate Terraform configurations
	@echo "TODO: Validate Terraform configurations"
	# @terraform -chdir=infra/terraform/modules/network/aws validate
	# @terraform -chdir=infra/terraform/modules/kubernetes-cluster/aws-eks validate

##@ Terraform

.PHONY: tf-plan-dev-aws
tf-plan-dev-aws: ## Plan dev environment on AWS
	@echo "TODO: Run terraform plan for dev/aws"
	# @cd infra/terraform/envs/dev/aws && terraform plan

.PHONY: tf-apply-dev-aws
tf-apply-dev-aws: ## Apply dev environment on AWS
	@echo "TODO: Run terraform apply for dev/aws"
	# @cd infra/terraform/envs/dev/aws && terraform apply

.PHONY: tf-destroy-dev-aws
tf-destroy-dev-aws: ## Destroy dev environment on AWS
	@echo "TODO: Run terraform destroy for dev/aws"
	# @cd infra/terraform/envs/dev/aws && terraform destroy

##@ Kubernetes

.PHONY: k8s-apply-dev
k8s-apply-dev: ## Apply Kubernetes manifests for dev
	@echo "TODO: Apply Kubernetes manifests"
	# @kubectl apply -k k8s/overlays/dev

.PHONY: k8s-diff-dev
k8s-diff-dev: ## Show diff for Kubernetes manifests for dev
	@echo "TODO: Show Kubernetes manifest diff"
	# @kubectl diff -k k8s/overlays/dev

##@ Operators

.PHONY: operator-redis-build
operator-redis-build: ## Build Redis operator
	@echo "TODO: Build Redis operator"
	# @cd operators/redis-operator && make docker-build

.PHONY: operator-redis-deploy
operator-redis-deploy: ## Deploy Redis operator
	@echo "TODO: Deploy Redis operator"
	# @cd operators/redis-operator && make deploy

.PHONY: operator-mongo-build
operator-mongo-build: ## Build MongoDB operator
	@echo "TODO: Build MongoDB operator"
	# @cd operators/mongo-operator && make docker-build

.PHONY: operator-secrets-build
operator-secrets-build: ## Build Secrets operator
	@echo "TODO: Build Secrets operator"
	# @cd operators/secrets-operator && make docker-build

##@ CLI Tools

BIN_DIR := bin
CLI_NAME := infractl
CLI_DIR := cmd/infractl

.PHONY: build-infractl
build-infractl: ## Build infractl CLI
	@echo "Building $(CLI_NAME)..."
	@mkdir -p $(BIN_DIR)
	@cd $(CLI_DIR) && go build -o ../../$(BIN_DIR)/$(CLI_NAME)
	@echo "CLI built at $(BIN_DIR)/$(CLI_NAME)"

.PHONY: install-infractl
install-infractl: ## Install infractl to $$GOPATH/bin (or $$HOME/go/bin)
	@echo "Installing $(CLI_NAME)..."
	@cd $(CLI_DIR) && go install
	@echo "Installed $(CLI_NAME) to $$(go env GOPATH)/bin"

.PHONY: build-infractl-all
build-infractl-all: ## Build infractl for macOS, Linux, ARM, etc.
	@echo "Building multi-platform binaries..."
	@mkdir -p $(BIN_DIR)
	@cd $(CLI_DIR) && GOOS=darwin GOARCH=arm64 go build -o ../../$(BIN_DIR)/$(CLI_NAME)-darwin-arm64
	@cd $(CLI_DIR) && GOOS=darwin GOARCH=amd64 go build -o ../../$(BIN_DIR)/$(CLI_NAME)-darwin-amd64
	@cd $(CLI_DIR) && GOOS=linux GOARCH=amd64 go build -o ../../$(BIN_DIR)/$(CLI_NAME)-linux-amd64
	@cd $(CLI_DIR) && GOOS=linux GOARCH=arm64 go build -o ../../$(BIN_DIR)/$(CLI_NAME)-linux-arm64
	@echo "All binaries built in $(BIN_DIR)/"

##@ Testing

.PHONY: test
test: ## Run all tests
	@echo "TODO: Run tests"
	# @go test -v ./...

.PHONY: test-unit
test-unit: ## Run unit tests
	@echo "TODO: Run unit tests"
	# @go test -v -short ./...

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "TODO: Run integration tests"
	# @go test -v -run Integration ./...

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	@echo "TODO: Run tests with coverage"
	# @go test -v -coverprofile=coverage.out ./...
	# @go tool cover -html=coverage.out -o coverage.html

##@ Documentation

.PHONY: docs
docs: ## Generate documentation
	@echo "TODO: Generate documentation"
	# @terraform-docs markdown infra/terraform/modules/ > docs/terraform-modules.md
	# @godoc -http=:6060

##@ Cleaning

.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	@rm -rf bin/
	@rm -rf coverage.out coverage.html
	@find . -name ".terraform" -type d -exec rm -rf {} +
	@find . -name "terraform.tfstate*" -delete

.PHONY: clean-all
clean-all: clean ## Clean everything including dependencies
	@echo "Cleaning all artifacts and caches..."
	@go clean -cache -modcache -testcache
