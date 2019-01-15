local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local madkub_common = import "madkub_common.jsonnet";
local kingdom = std.extVar("kingdom");
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";

local cert_name = "madkubinjector";

if flowsnakeconfig.is_test then
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "madkub-injector",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 2,
        selector: {
            matchLabels: {
                app: "madkub-injector"
            }
        },
        template: {
            metadata: {
                labels: {
                    app: "madkub-injector"
                },
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.toString({"certreqs": [{
                        "cert-type": "server",
                        "kingdom": kingdom,
                        "name": cert_name,
                        "role": "flowsnake.madkub-injector",
                        "san": ["madkub-injector.flowsnake", "madkub-injector.flowsnake.svc", "madkub-injector.flowsnake.svc.cluster.local"]
                    }]})
                }
            },
            spec: {
                serviceAccountName: "madkub-injector",
                containers: [
                    {
                        name: "injector",
                        image: flowsnake_images.madkub_injector,
                        imagePullPolicy: "Always",
                        ports: [{
                            containerPort: 8443
                        }],
                        volumeMounts: [
                            {
                                name: "kubeconfig",
                                mountPath: "/etc/kubeconfig",
                                readOnly: true
                            },
                            {
                                name: "spec",
                                mountPath: "/etc/madkub-container-spec",
                                readOnly: true
                            },
                            {
                                name: "volumes",
                                mountPath: "/etc/madkub-required-volumes",
                                readOnly: true
                            },
                            madkub_common.certs_mount
                        ],
                        args: [
                            "-madkubVolumesFile",
                            "/etc/madkub-required-volumes/volumes.jaysawn",
                            "-madkubContainerSpecFile",
                            "/etc/madkub-container-spec/spec.jaysawn",
                            "-kubeconfig",
                            "/etc/kubeconfig/kubeconfig.json",
                        ]
                    },
                    madkub_common.refresher_container(cert_name),
                ],
                initContainers: [ madkub_common.init_container(cert_name) ],
                volumes: [
                    {
                        name: "kubeconfig",
                        configMap: {
                            name: "insecure-injector-kubeconfig"
                        }
                    },
                    {
                        name: "spec",
                        configMap: {
                            name: "madkub-container-spec"
                        }
                    },
                    {
                        name: "volumes",
                        configMap: {
                            name: "madkub-required-volumes"
                        }
                    },
                    madkub_common.certs_volume,
                    madkub_common.tokens_volume,
                ] + (if !flowsnakeconfig.is_minikube then
                    certs_and_kubeconfig.kubeconfig_volume +
                    certs_and_kubeconfig.platform_cert_volume
                else []),
            }
        }
    }
} else "SKIP"
