local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local isEstateNotSkipper = configs.estate != "prd-skipper";

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
                                    key: "storage.salesforce.com/nodeprep-skipper",
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
                        imagePullPolicy: "Always",
                        image: storageimages.nodeprepskipper,
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
