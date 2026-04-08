function __kubens_current
    kubectl config view --minify -o jsonpath='{..namespace}' | read -l current
    test -n "$current"
    and echo $current
    or echo default
end

function __kubens_all
    kubectl get namespace -oname | cut -d/ -f2 | sort
end

function __kubens_set --description "Switch namespace with optional existence check"
    set -l ns $argv[1]
    set -l skip_verify $argv[2]

    if test -z "$skip_verify"
        kubectl get namespace "$ns" 1>/dev/null 2>/dev/null
        or begin
            echo "error: namespace '$ns' not found (use -k to skip verification)" >&2
            return 1
        end
    end

    kubectx --namespace=$ns
end

function kubens --description "Change or list kubernetes namespaces"
    argparse -X 1 h/help c/current i/interactive k/skip-verify l/list -- $argv

    if [ -n "$_flag_help" ]
        echo "Usage: $(status current-command) [OPTIONS] [NAME]"
        echo
        echo "Change or list Kubernetes namespaces"
        echo
        echo "Options:"
        echo "  -c, --current      Show the current namespace"
        echo "  -h, --help         This message"
        echo "  -i, --interactive  Select namespace interactively"
        echo "  -k, --skip-verify  Skip namespace existence check"
        echo "  -l, --list         Show all namespaces"
        return
    end

    kubectx --current 1>/dev/null
    or return

    if [ -n "$_flag_current" ]
        __kubens_current
        return
    end

    if [ -n "$_flag_list" ]
        __kubens_all
        return
    end

    if [ (count $argv) = 0 ]
        set kube_namespaces "$(__kubens_all)"
        or return

        set -l current_ns "$(__kubens_current)" 2>/dev/null

        if [ -n "$_flag_interactive" ]
            echo "$kube_namespaces" \
                | awk '/^'$current_ns'$/{ sub($0, $0 " \033[0;32m(current)\033[0m") }1' \
                | fzf --no-clear --ansi --no-sort --nth 1 --layout=reverse --height=50% --bind 'enter:become(echo {1})' \
                | read -l choice
            and __kubens_set $choice "$_flag_skip_verify"
        else
            echo "$kube_namespaces" | awk '/^'$current_ns'$/ { sub($0, "\033[0;33m" $0 "\033[0m") }1'
        end
    else
        __kubens_set $argv "$_flag_skip_verify"
    end
end
