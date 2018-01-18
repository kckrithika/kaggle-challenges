local portconfigs = import "portconfig.jsonnet";
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "nginx-ingress-controller",
        namespace: "flowsnake",
    },
    spec: {
        type: "NodePort",
        selector: {
            "k8s-app": "nginx-ingress-lb",
        },
        ports: [
            {
                name: "http",
                port: 80,
                protocol: "TCP",
                nodePort: portconfigs.flowsnake.nginx_ingress_http,
            },
            {
                name: "https",
                port: 443,
                protocol: "TCP",
                nodePort: portconfigs.flowsnake.nginx_ingress_https,
            },
        ],
    },
}
