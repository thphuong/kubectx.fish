# AGENTS.md

Instructions for AI agents (Claude Code, Copilot, Cursor, etc.) working on this project.

## Project Overview

**kubectx.fish** — Fish shell plugin for fast Kubernetes context and namespace switching.
Port of [ahmetb/kubectx](https://github.com/ahmetb/kubectx). Installed via [Fisher](https://github.com/jorgebucaran/fisher).

- **Language**: Fish shell (100%)
- **License**: MIT
- **Author**: Truong Hoang Phuong
- **Total LOC**: ~367

## Codebase Structure

```
functions/
  kubectx.fish   (218 LOC) — Core context switching, caching, config aggregation
  kubens.fish    (63 LOC)  — Namespace switching, delegates to kubectx
  kctx.fish      (3 LOC)   — Alias wrapper for kubectx
  kns.fish       (3 LOC)   — Alias wrapper for kubens
completions/
  kubectx.fish   (13 LOC)  — Tab completions for kubectx
  kubens.fish    (4 LOC)   — Tab completions for kubens
docs/                       — Project documentation
```

## Architecture

- `kubectx` is the core function — aggregates kubeconfig from `~/.kube/config` + `~/.kube/config.d/*.yml|yaml`
- Caches per-context configs in `~/.cache/kubectx/` with configurable TTL (default 1hr)
- `kubens` depends on `kubectx` — calls `kubectx --namespace=` internally
- `kctx`/`kns` are thin `--wraps` aliases for completion inheritance
- External deps: `kubectl` (required), `fzf` (optional, interactive), `bat`/`yq` (optional, pretty-print)

## Coding Conventions

### Naming
- **Public functions**: lowercase (`kubectx`, `kubens`)
- **Private helpers**: `__prefix_name` (`__kubectx_ls`, `__kubectx_set`)
- **Env vars**: `UPPER_SNAKE_CASE` (`KUBECONFIG_PATH`, `KUBECTX_CACHE_DIR`)
- **Local vars**: `lowercase_snake_case` with `set -l` or `set -f`
- **Flag vars**: auto-generated `_flag_*` from `argparse`

### Patterns
- Use `argparse` for all CLI argument parsing with mutual exclusion flags
- Use `or return` after fallible operations (argparse, kubectl calls)
- Check cross-platform: macOS uses `stat -f'%m'`, Linux uses `stat -c'%Y'`
- Conditional tool usage: check `command -v` before using optional tools
- Redirect noise: `1>/dev/null` or `2>/dev/null` where appropriate

### Function Structure
```fish
function my_func --description "Short description"
    argparse [flags] -- $argv
    or return
    # flag checks (early returns)
    # main logic
end
```

## Key Files to Understand

| File | When to Read |
|------|-------------|
| `functions/kubectx.fish` | Any context-related changes, caching, config aggregation |
| `functions/kubens.fish` | Namespace changes (thin layer over kubectx) |
| `completions/kubectx.fish` | Tab completion behavior |
| `docs/system-architecture.md` | Full architecture details |
| `docs/code-standards.md` | Detailed coding standards |

## Common Tasks

### Adding a new flag to kubectx
1. Add flag to `argparse` in `kubectx` function
2. Add flag handling block (early return pattern)
3. Update help text in `_flag_help` block
4. Add completion rule in `completions/kubectx.fish`
5. Update `README.md` usage section

### Adding a new flag to kubens
1. Add flag to `argparse` in `kubens` function
2. Add flag handling block
3. Update help text
4. Add completion rule in `completions/kubens.fish`
5. Update `README.md` usage section

## Important Notes

- No automated test suite — manual testing required
- Cache files are `chmod 0600` for security (contain kubeconfig secrets)
- Global mode (`-g`) creates symlink at `~/.kube/config` and backs up existing to `~/.kube/config.old`
- `KUBECONFIG` env var is set globally (`set -gx`) to affect the current shell session
- Fish completions files must match the command name exactly
