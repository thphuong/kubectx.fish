function __kubens_current
    kubectl config view --minify -o jsonpath='{..namespace}' | read -l current
    test -n "$current"
    and echo $current
    or echo default
end

function __kubens_all
    kubectl get namespace -oname | cut -d/ -f2 | awk '/^'(__kubens_current)'$/ { sub($0, "\033[0;33m" $0 "\033[0;37m") }1'
end

function __kubens_set
    kubectl config set-context --current --namespace=$argv[1]
end

function kubens --description "Change or list kubernetes namespaces"
    argparse -X 1 h/help c/current i/interactive -- $argv

    if [ -n "$_flag_h" ]
        echo "Usage: $(status current-command) [OPTIONS] [NAME]"
        echo
        echo "Change or list Kubernetes namespaces"
        echo
        echo "Options:"
        echo "  -c, --current      Show the current namespace"
        echo "  -h, --help         This message"
        echo "  -i, --interactive  Select namespace interactively"
        return
    end

    if [ -n "$_flag_c" ]
        __kubens_current
        return
    end

    if [ (count $argv) = 0 ]
        if [ -n "$_flag_i" ]
            __kubens_all | fzf --ansi --no-sort --tac | read -l choice
            and __kubens_set $choice
        else
            __kubens_all
        end
    else
        __kubens_set $argv
    end
end
