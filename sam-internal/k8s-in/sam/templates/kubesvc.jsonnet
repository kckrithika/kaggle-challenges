local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.kubedns then {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        labels: {
            "addonmanager.kubernetes.io/mode": "Reconcile",
            "k8s-app": "kube-dns",
            "kubernetes.io/cluster-service": "true",
            "kubernetes.io/name": "KubeDNS",
        } + configs.ownerLabel.sam,
        name: "kube-dns",
        namespace: "kube-system",
    },
    spec: {
        clusterIP: "10.254.208.255",
        ports: [
            {
                name: "dns",
                port: 53,
                protocol: "UDP",
                targetPort: 53,
            },
            {
                name: "dns-tcp",
                port: 53,
                protocol: "TCP",
                targetPort: 53,
            },
        ],
        selector: {
            "k8s-app": "kube-dns",
        },
        sessionAffinity: "None",
        type: "ClusterIP",
    },
} else "SKIP"
