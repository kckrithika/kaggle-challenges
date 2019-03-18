local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local util = import "util_functions.jsonnet";
local kingdom = std.extVar("kingdom");

if flowsnakeconfig.is_v1_enabled then
{
    local label_node = self.spec.template.metadata.labels,
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "flowsnake-fleet-service",
        },
        name: "flowsnake-fleet-service",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                app: label_node.app,
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "flowsnake-fleet-service",
                    app: "flowsnake-fleet-service",
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "FlowsnakeFleetService",
                },
            },
            spec: {
                containers: [
                    {
                        name: "flowsnake-fleet-service",
                        image: flowsnake_images.fleet_service,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                        ports: [
                            {
                                containerPort: 8080,
                                name: "fs30000",
                            },
                        ],
                        readinessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 8080,
                                scheme: "HTTP",
                            },
                        },
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 8080,
                                scheme: "HTTP",
                            },
                            initialDelaySeconds: 180,
                        },
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
                                name: "KUBERNETES_IMAGE_PULL_POLICY",
                                value: flowsnakeconfig.default_image_pull_policy,
                            },
                            {
                                name: "SPRING_PROFILES_ACTIVE",
                                value: "dev",
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
                            {
                                name: "version-mapping",
                                mountPath: "/etc/flowsnake/version-mapping",
                                readOnly: true,
                            },
                            {
                                mountPath: "/etc/flowsnake/secrets/flowsnake-ldap",
                                name: "flowsnake-ldap",
                                readOnly: true,
                            },
                            {
                                mountPath: "/etc/flowsnake/config/auth-namespaces",
                                name: "auth-namespaces",
                                readOnly: true,
                            },
                            {
                                mountPath: "/etc/flowsnake/config/auth-groups",
                                name: "auth-groups",
                                readOnly: true,
                            },
                        ] +
                        certs_and_kubeconfig.kubeconfig_volumeMounts +
                        certs_and_kubeconfig.platform_cert_volumeMounts,
                    },
                ],
                volumes: [
                    {
                        name: "flowsnake-ldap",
                        secret: {
                            secretName: "flowsnake-ldap",
                        },
                    },
                    {
                        name: "version-mapping",
                        configMap: {
                            name: "version-mapping",
                        },
                    },
                    {
                        name: "auth-namespaces",
                        configMap: {
                            name: "auth-namespaces",
                        },
                    },
                    {
                        name: "auth-groups",
                        configMap: {
                            name: "auth-groups",
                        },
                    },
                    {
                        name: "ajna-applog-logrecordtype-whitelist",
                        configMap: {
                            name: "ajna-applog-logrecordtype-whitelist",
                        },
                    },
                    {
                        name: "ajna-applog-logrecordtype-grants",
                        configMap: {
                            name: "ajna-applog-logrecordtype-grants",
                        },
                    },
                ] +
                certs_and_kubeconfig.kubeconfig_platform_volume +
                certs_and_kubeconfig.platform_cert_volume,
            },
        },
    },
} else "SKIP"
