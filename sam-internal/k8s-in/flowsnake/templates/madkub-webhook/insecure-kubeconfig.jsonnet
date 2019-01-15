local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_test then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "insecure-injector-kubeconfig",
        namespace: "flowsnake",
    },
    data: {
        "kubeconfig.json": std.toString({
            "clusters": {
                "default": {
                    "server": "https://kubernetes.default.svc:443",
                    "insecure-skip-tls-verify": true
                }
            },
            "users": {
                "default": {
                    "tokenFile": "/var/run/secrets/kubernetes.io/serviceaccount/token"
                }
            },
            "contexts": {
                "default": {
                    "cluster": "default",
                    "user": "default"
                }
            },
            "current-context": "default"
        })
    }
} else "SKIP"
