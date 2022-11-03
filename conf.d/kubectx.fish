set -gx KUBECONFIG

if test -f $HOME/.kube/config
    set -a --path KUBECONFIG $HOME/.kube/config
end

for config_file in $HOME/.kube/config.d/*
    set -a --path KUBECONFIG $config_file
end
