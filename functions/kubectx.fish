function __kubectx_ls
    set kubeconfig_files

    if test -f "$HOME/.kube/config"
        set -a kubeconfig_files "$HOME/.kube/config"
    end

    for config_file in "$HOME/.kube/config.d"/*.yml "$HOME/.kube/config.d"/*.yaml
        set -a kubeconfig_files "$config_file"
    end

    for config_file in $kubeconfig_files
        echo "$config_file"
    end
end

function __kubectx_path
    set kubeconfig_path

    for config_file in $(__kubectx_ls)
        set -a --path kubeconfig_path "$config_file"
    end

    echo "$kubeconfig_path"
end

function __kubectx_current
    kubectl config current-context
end

function __kubectx_all
    KUBECONFIG="$KUBECONFIG_PATH" kubectl config get-contexts -oname
end

function __kubectx_get
    argparse -X 1 c/color -- $argv

    set -f prettier cat

    if [ -n "$_flag_c" ]
        if command -v bat >/dev/null
            set -f prettier bat -lyaml
        else if command -v yq >/dev/null
            set -f prettier yq -r
        end
    end

    KUBECONFIG="$KUBECONFIG_PATH" kubectl config view --raw --minify --context "$argv[1]" -oyaml | $prettier
end

function __kubectx_set
    argparse -N 1 -X 1 g/global n/namespace= -- $argv
    or return

    if [ -z "$_flag_namespace" ]
        set _flag_namespace "default"
    end

    set cache_file "$KUBECTX_CACHE_DIR/$argv[1]~$_flag_namespace.yaml"

    set cache_file_mtime
    if [ ! -f "$cache_file" ]
        set cache_file_mtime 0
    else if [ $(uname -s | tr '[:upper:]' '[:lower:]') = "darwin" ]
        set cache_file_mtime (stat -f'%m' $cache_file)
    else
        set cache_file_mtime (stat -c'%Y' $cache_file)
    end

    if [ ! -f "$cache_file" ] || [ $(math "$(date +%s) - $cache_file_mtime") -ge "$KUBECTX_CACHE_EXPIRES_IN" ]
        mkdir -p "$KUBECTX_CACHE_DIR"
        __kubectx_get "$argv[1]" > "$cache_file"
        chmod 0600 "$cache_file"
        KUBECONFIG="$cache_file" kubectl config set-context --current --namespace="$_flag_namespace" 1>/dev/null
    end

    if [ -n "$_flag_global" ]
        if [ -f "$HOME/.kube/config" ]
            cp "$HOME/.kube/config" "$HOME/.kube/config.old"
        end

        ln -s "$cache_file" "$HOME/.kube/config"
        echo "Context '$argv[1]' written to ~/.kube/config"
        set kubeconfig_file "$HOME/.kube/config"
    else
        set kubeconfig_file "$cache_file"
    end

    set -gx KUBECONFIG "$kubeconfig_file"
    echo "Switched to context '$argv[1]'"
end

function kubectx --description "Change or list kubernetes contexts"
    argparse \
        -X 1 \
        -x 'i,c,l,s' \
        -x 'i,c,p,s' \
        -x 'g,c,l,s' \
        -x 'g,c,p,s' \
        -x 'n,c,l,s' \
        -x 'n,c,p,s' \
        cache-dir \
        e/cache-expires-in \
        c/current \
        f/no-cache \
        g/global \
        h/help \
        i/interactive \
        l/list \
        n/namespace= \
        p/path \
        s/show \
    -- $argv
    or return

    if [ -n "$_flag_help" ]
        echo "Usage: $(status current-command) [OPTIONS] [NAME]"
        echo
        echo "Change or list Kubernetes contexts"
        echo
        echo "Options:"
        echo "      --cache-dir         Set the cache directory"
        echo "  -e  --cache-expires-in  Set the cache expiration time"
        echo "  -c, --current           Show the current context"
        echo "  -f, --no-cache          Do not use existing cache for context"
        echo "  -g, --global            Set context globally (write to ~/.kube/config)"
        echo "  -h, --help              This message"
        echo "  -i, --interactive       Select context interactively"
        echo "  -l, --list              Show all kubeconfig files"
        echo "  -n, --namespace         Switch to the specified namespace"
        echo "  -p, --path              Show the kubeconfig path variable"
        echo "  -s, --show              Show the kubeconfig for a context"
        return
    end

    set -x KUBECONFIG_PATH "$(__kubectx_path)"
    or return

    if [ -n "$_flag_cache_dir" ]
        set -x KUBECTX_CACHE_DIR "$_flag_cache_dir"
    else
        set -x KUBECTX_CACHE_DIR "$HOME/.cache/kubectx"
    end

    if [ -n "$_flag_no_cache" ]
        set -x KUBECTX_CACHE_EXPIRES_IN 0
    else if [ -n "$_flag_cache_expires_in" ]
        set -x KUBECTX_CACHE_EXPIRES_IN "$_flag_cache_expires_in"
    else
        set -x KUBECTX_CACHE_EXPIRES_IN 3600 # 1 hour
    end

    if [ -n "$_flag_current" ]
        __kubectx_current
        return
    end

    if [ -n "$_flag_list" ] && [ -n "$_flag_path" ]
        __kubectx_ls
        return
    end

    if [ -n "$_flag_list" ]
        __kubectx_all
        return
    end

    if [ -n "$_flag_path" ]
        echo "$KUBECONFIG_PATH"
        return
    end

    if [ -n "$_flag_show" ]
        set -l ctx_name "$argv[1]"

        test -n "$ctx_name"
        or set -l ctx_name "$(__kubectx_current)"
        or return

        __kubectx_get -c "$ctx_name"
        return
    end

    if [ -n "$_flag_global" ]
        set -a passthrough_args "$_flag_global"
    end

    if [ -n "$_flag_namespace" ]
        if [ (count $argv) = 0 ]
            set -a argv "$(__kubectx_current 2>/dev/null)"
        end

        set -a passthrough_args "-n" "$_flag_namespace"
    end

    if [ (count $argv) = 0 ]
        set kube_contexts "$(__kubectx_all)"
        or return

        set current_context "$(__kubectx_current 2>/dev/null)"

        if [ -z "current_context" ]
            echo "$kube_contexts"
        end

        if [ -n "$_flag_interactive" ] && command -v fzf >/dev/null
            echo "$kube_contexts" \
                | awk '/^'$current_context'$/{ sub($0, $0 " \033[0;32m(current)\033[0m") }1' \
                | fzf --no-clear --ansi --no-sort --nth 1 --layout=reverse --height=50% --bind 'enter:become(echo {1})' \
                | read -l choice
            and __kubectx_set $passthrough_args $choice
        else
            echo "$kube_contexts" | awk '/^'$current_context'$/{ sub($0, "\033[0;33m" $0 "\033[0m") }1'
        end
    else
        __kubectx_set $passthrough_args $argv[1]
    end
end
