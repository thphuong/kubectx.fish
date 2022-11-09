function __kubectx_current
    kubectl config current-context
end

function __kubectx_all
    kubectl config get-contexts -oname | awk '/^'(__kubectx_current)'$/ { sub($0, "\033[0;33m" $0 "\033[0m") }1'
end

function __kubectx_set
    kubectl config use-context $argv
end

function kubectx --description "Change or list kubernetes contexts"
    argparse -X 1 h/help c/current i/interactive -- $argv

    if [ -n "$_flag_h" ]
        echo "Usage: $(status current-command) [OPTIONS] [NAME]"
        echo
        echo "Change or list Kubernetes contexts"
        echo
        echo "Options:"
        echo "  -c, --current      Show the current context"
        echo "  -h, --help         This message"
        echo "  -i, --interactive  Select context interactively"
        return
    end

    if [ -n "$_flag_c" ]
        __kubectx_current
        return
    end

    if [ (count $argv) = 0 ]
        if [ -n "$_flag_i" ]
            __kubectx_all | fzf --ansi --no-sort --tac | read -l choice
            and __kubectx_set $choice
        else
            __kubectx_all
        end
    else
        __kubectx_set $argv
    end
end
