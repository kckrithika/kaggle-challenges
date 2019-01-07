local portconfigs = import "portconfig.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
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
                # NodePort allowed range is different in Minikube; compensate accordingly.
                nodePort: if flowsnakeconfig.is_minikube then 30080 else portconfigs.flowsnake.nginx_ingress_http,
            },
            {
                name: "https",
                port: 443,
                protocol: "TCP",
                # NodePort allowed range is different in Minikube; compensate accordingly.
                nodePort: if flowsnakeconfig.is_minikube then 30443 else portconfigs.flowsnake.nginx_ingress_https,
            },
        ],
    },
}
