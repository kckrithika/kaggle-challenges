local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
if flowsnakeconfig.is_minikube_small then
"SKIP"
else
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "node-monitor",
        },
        name: "node-monitor",
        namespace: "default",
    },
    spec: {
        replicas: 3,
        template: {
            metadata: {
                labels: {
                    name: "node-monitor",
                    app: "node-monitor",
                },
            },
            spec: {
                 containers: [
                     {
                        name: "node-monitor",
                        image: flowsnake_images.node_monitor,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                        env: [
                            {
                                name: "CANARY_INTERVAL_SECONDS",
                                value: "60",
                            },
                            {
                                name: "CANARY_UNHEALTHY_THRESHOLD_SECONDS",
                                value: "60",
                            },
                            {
                                name: "CANARY_HEALTH_REJOIN_THRESHOLD_SECONDS",
                                value: "300",
                            },
                            {
                                name: "FLEET_NAME",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "name",
                                    },
                                },
                            },
                            {
                                name: "KUBECONFIG",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "kubeconfig",
                                    },
                                },
                            },
                        ],
                        volumeMounts: certs_and_kubeconfig.kubeconfig_volumeMounts +
                            certs_and_kubeconfig.platform_cert_volumeMounts,
                     },
                 ],
                 volumes: certs_and_kubeconfig.kubeconfig_platform_volume +
                            certs_and_kubeconfig.platform_cert_volume,
            },
        },
    },
}
