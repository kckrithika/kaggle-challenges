local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
if !flowsnakeconfig.kubedns_manifests_enabled then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        labels: {
            "addonmanager.kubernetes.io/mode": "Reconcile",
            "k8s-app": "kube-dns",
            "kubernetes.io/cluster-service": "true",
            "kubernetes.io/name": "KubeDNS",
        },
        name: "kube-dns",
        namespace: "kube-system",
    },
    spec: {
        clusterIP: "10.254.208.255",
        ports: if std.objectHas(flowsnakeimage.feature_flags, "kubedns_svc_10055") then [
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
            {
                name: "metrics",
                port: 10055,
                protocol: "UDP",
                targetPort: 10055,
            },
            {
                name: "metrics-tcp",
                port: 10055,
                protocol: "TCP",
                targetPort: 10055,
            },
        ] else [
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
}
