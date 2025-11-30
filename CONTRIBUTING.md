# Contributing to Hera

Thank you for your interest in contributing to Hera! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and professional in all interactions.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/yourusername/hera.git
   cd hera
   ```
3. **Set up development environment**
   ```bash
   make init
   ```

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or updates

### 2. Make Changes

- Follow the coding standards (see below)
- Write tests for new functionality
- Update documentation as needed
- Keep commits focused and atomic

### 3. Test Your Changes

```bash
# Format code
make fmt

# Lint code
make lint

# Run tests
make test

# Test Terraform configurations
make validate
```

### 4. Commit Your Changes

Follow conventional commits format:

```bash
git commit -m "feat: add new cluster creation feature"
git commit -m "fix: resolve network policy bug"
git commit -m "docs: update README with examples"
```

Commit message format:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:
- Clear title and description
- Reference any related issues
- Screenshots/examples if applicable
- Test results

## Coding Standards

### Terraform

- Use consistent formatting: `terraform fmt`
- Follow module interface contracts defined in READMEs
- Keep cloud-specific logic in cloud-specific modules
- Add comments for complex logic
- Use meaningful variable and resource names
- Document all variables and outputs

### Go

- Follow standard Go conventions
- Use `gofmt` for formatting
- Write godoc comments for public APIs
- Keep functions focused and small
- Write table-driven tests
- Use meaningful variable names
- Handle errors explicitly

### Kubernetes Manifests

- Use Kustomize for environment variations
- Follow Kubernetes best practices
- Include resource limits and requests
- Use appropriate labels and annotations
- Follow security best practices

## Testing Guidelines

### Terraform Testing

- Validate syntax: `terraform validate`
- Test plan execution: `terraform plan`
- Test in dev environment before prod
- Document any manual testing performed

### Go Testing

- Write unit tests for all packages
- Use table-driven tests where appropriate
- Mock external dependencies
- Aim for >80% code coverage
- Include integration tests for critical paths

### Operator Testing

- Unit test controller logic
- Use envtest for integration testing
- Test reconciliation loops thoroughly
- Test error handling and recovery
- Provide example CRs for manual testing

## Documentation

- Update README files when changing functionality
- Add godoc comments to Go code
- Document Terraform variables and outputs
- Include usage examples
- Update architecture diagrams if needed

## Pull Request Process

1. **Self-review your code**
2. **Ensure all tests pass**
3. **Update documentation**
4. **Request review from maintainers**
5. **Address review feedback**
6. **Squash commits if requested**
7. **Wait for approval and merge**

## Project Structure Guidelines

When adding new files:

### Terraform Modules
- Place in `infra/terraform/modules/`
- Follow the module interface contract
- Include README with usage examples

### Kubernetes Operators
- Place in `operators/`
- Follow Operator SDK structure
- Include CRD examples in `config/samples/`

### Go Packages
- Place in `pkg/` for libraries
- Place in `cmd/` for binaries
- Follow Go project layout standards

### Kubernetes Manifests
- Place base manifests in `k8s/base/`
- Place overlays in `k8s/overlays/{env}/`
- Use Kustomize for composition

## Questions?

If you have questions:
- Open a GitHub issue for discussion
- Tag it with `question` label
- Provide context and what you've tried

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
