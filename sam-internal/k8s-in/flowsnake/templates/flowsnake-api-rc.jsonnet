local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
local util = import "util_functions.jsonnet";
local kingdom = std.extVar("kingdom");
{
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
                app: "flowsnake-fleet-service",
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "flowsnake-fleet-service",
                    app: "flowsnake-fleet-service",
                },
            },
            spec: {
                containers: [
                    {
                        name: "flowsnake-fleet-service",
                        image: flowsnakeimage.fleet_service,
                        imagePullPolicy: if flowsnakeconfig.is_minikube then "Never" else "Always",
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
                                value: if flowsnakeconfig.is_minikube then "Never" else "Always",
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
                        ] + (if flowsnakeconfig.is_098_registry_config then [
                            {
                                name: "DOCKER_STRATA_REGISTRY_URL",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "strata_registry",
                                    },
                                },
                            },
                        ] else []) + if util.is_production(kingdom) then [
                            {
                                name: "FLOWSNAKE_CONFIG_OVERRIDES",
                                value: " { flowsnake.tenantCertificateConfig.imageName: \"" + flowsnakeimage.madkub + "\" } ",
                            },
                        ] else [],
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
                        flowsnakeconfigmapmount.kubeconfig_volumeMounts +
                        flowsnakeconfigmapmount.platform_cert_volumeMounts,
                    },
                ] + if flowsnakeconfig.is_test then [
                    {
                        name: "beacon",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/servicemesh/beacon:1.0.0",
                        args: ["-endpoint", "flowsnake:DATACENTER_ALLENV:8080", "-path", "-.-.PRD.-.kevin", "-spod", "NOPE"],
                    },
                ] else [],
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
                ] +
                flowsnakeconfigmapmount.kubeconfig_platform_volume +
                flowsnakeconfigmapmount.platform_cert_volume,
            },
        },
    },
}
