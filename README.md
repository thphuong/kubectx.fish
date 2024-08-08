# kubectx and kubens for Fish

A port of [ahmetb/kubectx](https://github.com/ahmetb/kubectx) for the Fish shell.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher)

```sh
fisher install thphuong/kubectx.fish
```

## Usage

```text
Usage: kubectx [OPTIONS] [NAME]

Change or list Kubernetes contexts

Options:
      --cache-dir         Set the cache directory
  -e  --cache-expires-in  Set the cache expiration time
  -c, --current           Show the current context
      --no-cache          Do not use existing cache for context
  -g, --global            Set context globally (write to ~/.kube/config)
  -h, --help              This message
  -i, --interactive       Select context interactively
  -l, --list              Show all kubeconfig files
  -p, --path              Show the kubeconfig path variable
  -s, --show              Show the kubeconfig for a context
```

```text
Usage: kubens [OPTIONS] [NAME]

Change or list Kubernetes namespaces

Options:
  -c, --current      Show the current namespace
  -h, --help         This message
  -i, --interactive  Select namespace interactively
```
