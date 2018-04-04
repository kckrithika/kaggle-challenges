local configs = import "config.jsonnet";
local isEstateNotSkipper = configs.estate != "prd-skipper";

local nodestartup = |||
    echo 'Starting creation...'; 
    rm -rf '/mnt/parent-node-mnt/lvhdd' || true;
    for c in $(seq 0 3); do
        echo "creating hdd $c"
        mkdir -p "/mnt/parent-node-mnt/lvhdd/disk$c" || true;
    done;
    rm -rf "/mnt/lvssd" || true;
    for c in $(seq 0 0); do
        echo "creating ssd $c"
        mkdir -p "/mnt/parent-node-mnt/lvssd/disk$c" || true;
    done;
    node_num=$(echo ${MY_NODE_NAME: -1});
    nodelen=$(kubectl get nodes --no-headers -o=custom-columns=NAME:.metadata.name | wc -l);
    kubectl label node $MY_NODE_NAME "node.sam.sfdc.net/rack=$node_num" --overwrite;
    kubectl label node $MY_NODE_NAME "failure-domain.beta.kubernetes.io/region=us-westregion-$node_num" --overwrite; 
    kubectl label node $MY_NODE_NAME "failure-domain.beta.kubernetes.io/zone=us-westzone-node$node_num" --overwrite;
    if [ "$nodelen" == 3 ]; then
        echo "Less than 3 worker nodes, removing noschedule taint from master";
        kubectl taint nodes -l node-role.kubernetes.io/master="true"   node-role.kubernetes.io/master- 2>&1 > /dev/null;
    fi;
    echo "Node Creation completed..."; 
    kubectl label node $MY_NODE_NAME "storage.salesforce.com/nodeprep=true" --overwrite;
    while true;
    do
        sleep 21600;
    done;
|||;

local internal = {
    create_namespace(name):: (
       {
            apiVersion: "v1",
            kind: "Namespace",
            metadata: {
                name: name,
            },
       }
    ),
};

local node_initializer_ds = {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels:
        {
            cloud: "storage",
            team: "storage-foundation",
        },
        name: "node-initializer",
        namespace: "storage-foundation",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    app: "node-initializer",
                    cloud: "storage",
                    team: "storage-foundation",
                },
            },
            spec: {
                tolerations: [
                    {
                        key: "node-role.kubernetes.io/master",
                        operator: "Exists",
                        effect: "NoSchedule",
                    },
                ],
                affinity: {
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [
                            {
                                matchExpressions: [
                                {
                                    key: "storage.salesforce.com/nodeprep",
                                    operator: "DoesNotExist",
                                },
                                ],
                            },
                            ],
                        },
                    },
                },
                containers: [
                    {
                        command: ["/bin/sh", "-c"],
                        args: [
                                nodestartup,
                        ],
                        env: [
                            {
                               name: "MY_NODE_NAME",
                               valueFrom: {
                                   fieldRef: {
                                        fieldPath: "spec.nodeName",
                                    },
                                },
                            },
                            {
                               name: "KUBEVAR_POD_NAME",
                               valueFrom: {
                                    fieldRef: {
                                       fieldPath: "metadata.name",
                                    },
                                },
                            },
                            {
                                name: "KUBEVAR_POD_NAMESPACE",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "metadata.namespace",
                                    },
                                },
                            },
                        ],
                        image: "lachlanevenson/k8s-kubectl:v1.10.0",
                        name: "initializer",
                        securityContext: {
                            privileged: true,
                        },
                        volumeMounts: [
                            {
                                mountPath: "/mnt/parent-node-mnt",
                                name: "parent-node-mnt",
                            },
                        ],
                    },
                ],
                volumes: [
                    {
                        hostPath: {
                            path: "/mnt",
                        },
                        name: "parent-node-mnt",
                    },
                    {
                        emptyDir: {},
                        name: "container-log-vol",
                    },
                ],
            },
        },
    },
};

if !isEstateNotSkipper then {
apiVersion: "v1",
items: configs.filter_empty([
    internal.create_namespace("sam-system"),
    internal.create_namespace("storage-foundation"),
    internal.create_namespace("legostore"),
    node_initializer_ds,
    ]),
kind: "List",
metadata: {},
} else "SKIP"
