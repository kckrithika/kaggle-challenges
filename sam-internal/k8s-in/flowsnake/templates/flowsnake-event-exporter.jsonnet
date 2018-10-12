local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local flag_fs_metric_labels = std.objectHas(flowsnake_images.feature_flags, "fs_metric_labels");
local flag_fs_matchlabels = std.objectHas(flowsnake_images.feature_flags, "fs_matchlabels");

if flowsnakeconfig.is_minikube then
"SKIP"
else
{
    local label_node = self.spec.template.metadata.labels,
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "flowsnake-event-exporter",
        },
        name: "flowsnake-event-exporter",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 1,
        [if flag_fs_matchlabels then "selector"]: {
            matchLabels: {
                app: label_node.app,
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "flowsnake-event-exporter",
                    app: "flowsnake-event-exporter",
                } + if flag_fs_metric_labels then {
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "FlowsnakeEventExporter",
                } else {},
            },
            spec: {
                containers: [
                    {
                        name: "flowsnake-event-exporter",
                        image: flowsnake_images.event_exporter,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                        env: [
                            {
                                name: "FLOWSNAKE_FLEET",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "name",
                                    },
                                },
                            },
                            {
                                name: "DOCKER_REGISTRY_URL",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "registry",
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
                            {
                                name: "DOCKER_STRATA_REGISTRY_URL",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "strata_registry",
                                    },
                                },
                            },
                        ],
                        volumeMounts: [
                        ] +
                        certs_and_kubeconfig.kubeconfig_volumeMounts +
                        certs_and_kubeconfig.platform_cert_volumeMounts,
                    },
                ],
                volumes: [
                ] +
                certs_and_kubeconfig.kubeconfig_platform_volume +
                certs_and_kubeconfig.platform_cert_volume,
            },
        },
    },
}
