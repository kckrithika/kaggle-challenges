local estate = std.extVar("estate");

if estate == "prd-data-flowsnake" then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        labels: {
            app: "pseudo-kubeapi",
        },
        name: "pseudo-kubeapi",
        namespace: "flowsnake",
    },
    spec: {
        ports: [
            {
                name: "http",
                port: 40001,
                protocol: "TCP",
                targetPort: 7002,
            },
        ],
        selector: {
            app: "pseudo-kubeapi",
        },
        sessionAffinity: "None",
        type: "ClusterIP",
    },
} else "SKIP"
