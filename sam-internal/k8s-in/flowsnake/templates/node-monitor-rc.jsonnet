local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
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
                        image: flowsnakeimage.node_monitor,
                        imagePullPolicy: "IfNotPresent",
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
                        volumeMounts: flowsnakeconfigmapmount.kubeconfig_volumeMounts +
                            flowsnakeconfigmapmount.platform_cert_volumeMounts,
                     },
                 ],
                 volumes: flowsnakeconfigmapmount.kubeconfig_platform_volume +
                     flowsnakeconfigmapmount.platform_cert_volume,
            },
        },
    },
}
