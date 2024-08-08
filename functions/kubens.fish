function __kubens_current
    kubectl config view --minify -o jsonpath='{..namespace}' | read -l current
    test -n "$current"
    and echo $current
    or echo default
end

function __kubens_all
    kubectl get namespace -oname | cut -d/ -f2
end

function __kubens_set
    kubectl config set-context --current --namespace=$argv[1]
end

function kubens --description "Change or list kubernetes namespaces"
    argparse -X 1 h/help c/current i/interactive l/list -- $argv

    if [ -n "$_flag_h" ]
        echo "Usage: $(status current-command) [OPTIONS] [NAME]"
        echo
        echo "Change or list Kubernetes namespaces"
        echo
        echo "Options:"
        echo "  -c, --current      Show the current namespace"
        echo "  -h, --help         This message"
        echo "  -i, --interactive  Select namespace interactively"
        echo "  -l, --list         Show all namespaces"
        return
    end

    kubectx --current 1>/dev/null
    or return

    if [ -n "$_flag_c" ]
        __kubens_current
        return
    end

    if [ -n "$_flag_l" ]
        __kubens_all
        return
    end

    if [ (count $argv) = 0 ]
        set kube_namespaces "$(__kubens_all)"
        or return

        set -l current_ns "$(__kubens_current)" 2>/dev/null

        if [ -n "$_flag_i" ]
            echo "$kube_namespaces" \
                | awk '/^'$current_ns'$/{ sub($0, $0 " \033[0;32m(current)\033[0m") }1' \
                | fzf --no-clear --ansi --no-sort --nth 1 --layout=reverse --height=50% --bind 'enter:become(echo {1})' \
                | read -l choice
            and __kubens_set $choice
        else
            echo "$kube_namespaces" | awk '/^'$current_ns'$/ { sub($0, "\033[0;33m" $0 "\033[0m") }1'
        end
    else
        __kubens_set $argv
    end
end
