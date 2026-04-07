# kubectx and kubens for Fish

A port of [ahmetb/kubectx](https://github.com/ahmetb/kubectx) for the Fish shell, providing fast context and namespace switching for Kubernetes.

## Features

- **Multi-kubeconfig support**: Aggregate configs from `~/.kube/config` and `~/.kube/config.d/*.yml|yaml`
- **Smart caching**: Per-context cache with 1-hour TTL (configurable)
- **Interactive selection**: fzf integration for visual context/namespace picker
- **Cross-platform**: macOS (Darwin) and Linux compatibility
- **Optional pretty-print**: Display configs via bat or yq if available
- **Tab completions**: Dynamic context and namespace suggestions
- **Zero dependencies**: Works without fzf, bat, or yq (all optional)

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher)

```sh
fisher install thphuong/kubectx.fish
```

### Dependencies

**Required**: Fish shell 3.0+, kubectl 1.14+

**Optional**: fzf (interactive mode), bat or yq (pretty-print)

## Quick Start

```sh
# List all contexts
kubectx

# Switch context (interactive with fzf, or specify name)
kubectx my-cluster
kubectx -i  # fzf selection

# Show current context
kubectx -c

# List namespaces
kubens

# Switch namespace
kubens kube-system
kubens -i  # fzf selection

# Show current namespace
kubens -c

# Short aliases
kctx my-cluster
kns kube-system
```

## Usage

```text
Usage: kubectx [OPTIONS] [NAME]

Change or list Kubernetes contexts

Options:
      --cache-dir         Set the cache directory
  -e  --cache-expires-in  Set the cache expiration time
  -c, --current           Show the current context
  -f, --no-cache          Do not use existing cache for context
  -g, --global            Set context globally (write to ~/.kube/config)
  -h, --help              This message
  -i, --interactive       Select context interactively
  -l, --list              Show all kubeconfig files
  -p, --path              Show the kubeconfig path variable
  -s, --show              Show the kubeconfig for a context
  -n, --namespace=NS      Switch to the specified namespace
```

```text
Usage: kubens [OPTIONS] [NAME]

Change or list Kubernetes namespaces

Options:
  -c, --current      Show the current namespace
  -h, --help         This message
  -i, --interactive  Select namespace interactively
  -l, --list         List all namespaces
```

## Architecture Overview

kubectx.fish aggregates multiple kubeconfigs, intelligently caches parsed configs, and provides fast context/namespace switching via session-scoped or global KUBECONFIG environment variables.

**Key components**:
- **Kubeconfig aggregation**: Merges `~/.kube/config` + `~/.kube/config.d/*.yml|yaml` into single KUBECONFIG_PATH
- **Smart caching**: Per-context YAML cache in `~/.cache/kubectx/` with time-based TTL (default 1 hour)
- **Interactive selection**: fzf-powered picker highlights current context/namespace
- **Global/session modes**: `-g` flag writes to `~/.kube/config` (persistent); default is session-scoped (temporary)

See [docs/system-architecture.md](./docs/system-architecture.md) for detailed architecture, data flow, and component diagrams.

## Documentation

Complete documentation available in `./docs/`:

- **[Project Overview & PDR](./docs/project-overview-pdr.md)** — Features, requirements, success criteria
- **[Codebase Summary](./docs/codebase-summary.md)** — File structure, functions, LOC, data structures
- **[Code Standards](./docs/code-standards.md)** — Fish shell conventions, naming, patterns, best practices
- **[System Architecture](./docs/system-architecture.md)** — Component diagrams, data flow, caching strategy, security
- **[Project Roadmap](./docs/project-roadmap.md)** — Version history, planned features, maintenance schedule

## Examples

### Basic switching
```sh
# List and pick interactively
kubectx -i

# Switch by name
kubectx prod-cluster

# Get current
kubectx -c
```

### Namespace operations
```sh
# List namespaces
kubens -l

# Switch namespace
kubens default

# Interactive picker
kubens -i

# Get current
kubens -c
```

### Advanced options
```sh
# Show kubeconfig for context
kubectx -s my-cluster

# Print aggregated KUBECONFIG_PATH
kubectx -p

# Set context globally (persistent)
kubectx -g my-cluster  # Backup of old config saved to ~/.kube/config.old

# Bypass cache (force refresh)
kubectx -f prod-cluster

# Custom cache TTL (30 min instead of 1 hour)
kubectx -e 1800 prod-cluster

# Set namespace with context
kubectx -n kube-system my-cluster
```

## Tips

1. **fzf integration**: Install fzf for interactive selection with `kubectx -i` and `kubens -i`
2. **Pretty-print**: Install bat or yq to colorize `kubectx -s` output
3. **Aliases**: Use `kctx` and `kns` as shorter alternatives
4. **Completion**: Tab completion works for both contexts and namespaces
5. **Cache management**: Clear cache with `rm -rf ~/.cache/kubectx/` if needed

## Performance

- **Context switch (cache hit)**: ~10-20ms
- **Context switch (cache miss)**: ~200-500ms
- **Namespace switch**: ~50ms
- **Interactive selection**: Depends on fzf startup (~100-200ms)

## Known Limitations

- `kubens` requires an active Kubernetes context (validates via `kubectx --current`)
- Cache invalidation is time-based only (no content hash verification)
- Interactive namespace flag (`kubens -i`) currently uses fzf directly; `kubectx -i` preferred for contexts
- Global mode (`-g`) relies on symlink to session cache; consider session mode for multi-session workflows

## License

MIT License © 2022 Truong Hoang Phuong. See [LICENSE](./LICENSE) for details.
