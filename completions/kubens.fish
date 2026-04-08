complete -f -c kubens
complete -f -c kubens -a '-c --current' -d "show the current namespace"
complete -f -c kubens -a '-h --help' -d "show the help message"
complete -f -c kubens -a '-i --interactive' -d "select namespace interactively"
complete -f -c kubens -a '-k --skip-verify' -d "skip namespace existence check"
complete -f -c kubens -a '-l --list' -d "list all namespaces"
complete -f -c kubens -n "kubectx --current 2>&1 >/dev/null && [ (count (commandline -opc | string replace -ar '\-{1,2}\S+' '' | string split -n ' ')) -le 1 ]" -a "(kubectl get ns -oname | cut -d/ -f2)"
