# Command Line Tools

This directory contains CLI tools for the Hera platform.

## Tools

### infractl

A unified CLI for managing Hera Kubernetes clusters across cloud providers.

## Directory Structure

```
cmd/
  infractl/
    main.go           # Entry point
    cmd/              # Cobra commands
      root.go
      create.go
      delete.go
      get.go
      update.go
    README.md
```

## Building

```bash
# Build all tools
make build

# Build specific tool
cd cmd/infractl
go build -o infractl

# Install to $GOPATH/bin
go install
```

## Testing

```bash
# Run tests
go test ./cmd/...

# Run with coverage
go test -cover ./cmd/...
```

## Distribution

Tools can be distributed via:
1. **GitHub Releases**: Binary artifacts
2. **Homebrew**: Package for macOS/Linux
3. **Container Images**: Dockerized tools
4. **Go Install**: `go install github.com/yourorg/hera/cmd/infractl@latest`
