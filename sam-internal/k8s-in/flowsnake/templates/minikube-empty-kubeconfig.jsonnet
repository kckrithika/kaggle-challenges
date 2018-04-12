local flowsnakeconfig = import "flowsnake_config.jsonnet";
if !flowsnakeconfig.is_minikube then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "minikube-empty-kubeconfig",
        namespace: "flowsnake",
    },
    data: {
        kubeconfig: "",
    },
}
