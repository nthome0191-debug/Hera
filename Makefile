# Hera Platform Makefile
# TODO: Implement build targets for the entire platform

.PHONY: help
help: ## Display this help message
	@echo "Hera Platform Build System"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

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
