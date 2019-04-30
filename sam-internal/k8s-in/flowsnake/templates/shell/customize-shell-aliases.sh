# Control which alias sets you want in customize-shell-user-overrides.sh

# TODO: with an alternate kc definition, these can work on workstations. Do that, then add the git ones as well.
# TODO: Is there a way to programatically generate all the aliases of a particlar type? E.g. bash*?

cat << 'EOF' > ~/aliases
#
# Do not edit here. Contents mastered from https://git.soma.salesforce.com/sam/manifests/blob/master/sam-internal/k8s-in/flowsnake/templates/shell/customize-shell-aliases.sh' > ~/aliases
#
EOF


if [[ ${ALIASES_BASE:-true} == "true" ]]; then
cat << 'EOF' >> ~/aliases

# ALIASES_BASE
#
#
# Conventions
# *f, *k, *s operate on the flowsnake, kube-system, and sam-system namespaces respectively.
# *n <namespace> operates on the specified namespace
# Where applicable, *a operates on all namespaces, and <no suffix> operates on the default namespace.

# -----------------------------------
# Shorthand for running kubectl

kc() {
    sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig "$@"
}

customize-shell-install() {
    kc
}

kcf() {
    kc -n flowsnake "$@"
}

kcft() {
    kc -n flowsnake-test "$@"
}

kcfw() {
    kc -n flowsnake-watchdog "$@"
}

kck() {
    kc -n kube-system "$@"
}

kcs() {
    kc -n sam-system "$@"
}

kcu() {
    kc -n $USER "$@"
}

kca() {
    kc "$@" --all-namespaces
}

# -----------------------------------
# Terminal access

# With pod as argument:
# bashf flowsnake-fleet-service-3386788146-37689
#
# With optional container specification:
# bashf nginx-ingress-controller-1441994177-scdt1 -c beacon

bashf() {
    kcf exec -it "$@" env COLUMNS=$COLUMNS LINES=$LINES -- /bin/bash
}

bashft() {
    kcft exec -it "$@" env COLUMNS=$COLUMNS LINES=$LINES -- /bin/bash
}

bashfw() {
    kcfw exec -it "$@" env COLUMNS=$COLUMNS LINES=$LINES -- /bin/bash
}

bashk() {
    kck exec -it "$@" env COLUMNS=$COLUMNS LINES=$LINES -- /bin/bash
}

bashs() {
    kcs exec -it "$@" env COLUMNS=$COLUMNS LINES=$LINES -- /bin/bash
}

bashu() {
    kcu exec -it "$@" env COLUMNS=$COLUMNS LINES=$LINES -- /bin/bash
}

bashn() {
    kc -n $1 exec -it "${@:2}" env COLUMNS=$COLUMNS LINES=$LINES -- /bin/bash
}

EOF
fi

if [[ ${ALIASES_FLOWSNAKE_V1:-true} == "true" ]]; then
cat << 'EOF' >> ~/aliases

# ALIASES_FLOWSNAKE_V1

# Conventions
# *e <environment-name> operates on the namespace for the specified environment.

kce() {
    NAMESPACE=$(fs_env_ns $1) || return 1
    shift
    kc -n ${NAMESPACE} "$@"
}

# -----------------------------------
# Flowsnake environments

# List Flowsnake environments and their namespaces
fs_envs() {
    {
        echo "ENVIRONMENT|OWNER/PKI|VERSION|NAMESPACE|CREATED";
        # LDAP groups can contain spaces, so use | as delimiter instead.
        kcf get rc -o template --template '{{ range .items }}{{ .metadata.labels.environment }}{{"|"}}{{ or .metadata.annotations.ownerGroup .metadata.annotations.pkiNamespace }}{{"|"}}{{ or .metadata.labels.platformVersion .metadata.annotations.platformVersion }}{{"|"}}{{ .metadata.name }}{{"|"}}{{ .metadata.creationTimestamp }}{{"\n"}}{{ end }}' | grep -v "^<no value" | sed -e 's/|env-svc-/|flowsnake-/' | sort
    } | column -t -s "|"
}

# Return namespace for specified Flowsnake environment
fs_env_ns() {
    NAMESPACE=$(kc get namespaces -o template --template='{{ range .items }}{{ $NAME := .metadata.name }}{{ range $KEY, $VALUE :=.metadata.labels }}{{ if (and (or (eq $KEY "flowsnakeEnvironmentName") (eq $KEY "environmentName")) (eq $VALUE "'$1'") ) }}{{ $NAME }}{{ end }}{{ end }}{{ end }}')

    if [[ -z ${NAMESPACE} ]]; then
        echo "Error: environment '$1' not found" 1>&2
        return 1
    fi

    echo $NAMESPACE
}

# List everything running in the specified Flowsnake environment
fs_env() {
    NAMESPACE=$(fs_env_ns $1) && kc get all --namespace ${NAMESPACE}
}

bashe() {
    NAMESPACE=$(fs_env_ns $1) || return 1
    kc -n ${NAMESPACE} exec -it "${@:2}" env COLUMNS=$COLUMNS LINES=$LINES -- /bin/bash
}

# -----------------------------------l
# Identifying common pods and their nodes

# Examples:
# kcf logs $(fleet-svc) --tail=5
# bashf $(ingress) -c beacon
# env-svc-node my-environment

fleet-svc() {
   kcf get pods -l app=flowsnake-fleet-service -o jsonpath='{.items..metadata.name}'
}
fleet-svc-node() {
   kcf get pods -l app=flowsnake-fleet-service -o jsonpath='{.items..spec.nodeName}'
}
ingress() {
   kcf get pods -l name=nginx-ingress-lb -o jsonpath='{.items..metadata.name}'
}
ingress-node() {
   kcf get pods -l name=nginx-ingress-lb -o jsonpath='{.items..spec.nodeName}'
}
env-svc() {
   kcf get pods -l app=environment-service,environment=$1 -o jsonpath='{.items..metadata.name}'
}
env-svc-node() {
   kcf get pods -l app=environment-service,environment=$1 -o jsonpath='{.items..spec.nodeName}'
}
EOF
fi


if [[ ${ALIASES_EXPERIMENTAL:-false} == "true" ]]; then
cat << 'EOF' >> ~/aliases

# ALIASES_EXPERIMENTAL

# TODO: what about labels on things other than pods?
# List labels
labelsn () {
    kc -n $1 get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-r
}
labelsa() {
    kca get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-rol
}
labelsf() {
    kcf get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-role)=
}
labelsft() {
    kcft get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-role)=
}
labelsfw() {
    kcfw get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-role)=
}
labelsk() {
    kck get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-role)=
}
labelss() {
    kcs get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-role)=
}
labelsu() {
    kcu get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-role)=
}
labelse() {
    kce $1 get pods -o template --template '{{ range .items }}{{ range $key, $value := .metadata.labels}}{{ $key }}{{"="}}{{ $value}}{{"\n"}}{{ end }}{{ end }}' | sort | uniq | grep -P '(app|componentName|flowsnakeRole|name|spark-rol
}

# TODO: add impl's for new kc* flavors

# Search for labels
# Example usage: greplabelsf "w.*operator"
greplabelsn () {
    labels $1 | grep "${@:2}"
}
greplabelsa() {
    labelsa | grep "$@"
}
greplabelsf() {
    labelsf | grep "$@"
}
greplabelss() {
    labelss | grep "$@"
}
greplabelsk() {
    labelsk | grep "$@"
}
greplabelse() {
    labelse $1 | grep "${@:2}"
}

# TODO: probably user expects a single result, should fail if multiple
# TODO: probably user wants to exclude pods that are Terminating and get the label for the new pod
# TODO: add impl's for new kc* flavors

# Name of pod with label
# Example usage: kcf logs $(podswithlabelf app=watchdog-spark-operator)
podswithlabeln() {
    kc -n $1 get pods -l $2 -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podswithlabela() {
    kca -l $1 get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podswithlabelf() {
    kcf -l $1 get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podswithlabels() {
    kcs -l $1 get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podswithlabelk() {
    kck -l $1 get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podswithlabele() {
    kce $1 -l $2 get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}

# Name of pod grepping for label
# Example usage: kcf logs $(podsgreplabelf "watchdog.*oper")
podsgreplabeln() {
    kc -n $1 get pods -l $(greplabelsn "$@") -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podsgreplabela() {
    kca -l $(greplabelsa "$@") get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podsgreplabelf() {
    kcf -l $(greplabelsf "$@") get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podsgreplabels() {
    kcs -l $(greplabelss "$@") get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podsgreplabelk() {
    kck -l $(greplabelsk "$@") get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}
podsgreplabele() {
    kce $1 -l $(greplabelse "$@") get pods -o template --template '{{ range .items }}{{ .metadata.name }}{{" "}}{{ end}}'
}


EOF
fi


if [[ ${ALIASES_LEGACY:-false} == "true" ]]; then
cat << 'EOF' >> ~/aliases

# ALIASES_LEGACY

# -----------------------------------
# Resource consumption

# pod_count_per_node
pcpn() {
    kca get pods -o wide | grep -v NODE | awk '{print $NF}' | sort | uniq -c | sort -n
}

# resources_consumed_per_env
rcpe() {
    kca describe node |  grep -vE '(^|\s)flowsnake($|\s)' | grep flowsnake- | awk '{print $1,index($3, "m") != 0? $3/1000:$3,$7}' |  awk '{arr[$1]+=$2;arr2[$1]+=$3} END {for (i in arr) {printf "%s %d(cores) %d(gb)\n", i,arr[i],arr2[i]/1073741824}}' > usageEnv; kca get pods -L flowsnakeEnvironmentName | grep -v FLOWSNAKEENVIRONMENTNAME | grep -vE '(^|\s)flowsnake($|\s)'| awk '{print $7 == null?"SKIP":$1,$7}' | grep -v "SKIP" | sort | uniq -c | sort -n > envName; awk 'BEGIN {FS=OFS=" "} NR==FNR {a[$2]=$3;b[$2]=$1;next} {printf "%s | %s | %s | %s | %s(pods)\n",a[$1],$1,$2,$3,b[$1]}' envName usageEnv | column -t -s "|"; rm envName; rm usageEnv
}

EOF
fi
