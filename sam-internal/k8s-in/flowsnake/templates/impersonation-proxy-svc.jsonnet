local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
if flowsnake_config.is_minikube || std.objectHas(flowsnake_images.feature_flags, "impersonation_proxy") then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "impersonation-proxy",
        namespace: "flowsnake",
    },
    spec: {
        ports: [
            {
                name: "https",
                # Ingress controller is already on port 443
                port: 444,
                targetPort: 443,
                protocol: "TCP",
            },
        ],
        selector: {
            app: "impersonation-proxy",
        },
        type: "ClusterIP",
    },
} else "SKIP"
