local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
if std.objectHas(flowsnakeimage.feature_flags, "node_controller") then
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "node-controller",
                        image: flowsnakeimage.node_controller,
                        command: [
                            "/sam/node-controller",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--hostsConfigFile=/sfdchosts/hosts.json",
                        ],
                        volumeMounts: [
                          {
                            mountPath: "/sfdchosts",
                            name: "sfdchosts",
                          },
                        ] +
                        certs_and_kubeconfig.kubeconfig_platform_volumeMounts +
                        certs_and_kubeconfig.platform_cert_volumeMounts,
                        env: [
                            {
                                name: "NODE_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "spec.nodeName",
                                    },
                                },
                            },
                            {
                              name: "KUBECONFIG",
                              value: "/etc/kubernetes/kubeconfig-platform",
                            },
                        ],
                    },
                ],
                volumes: [
                  {
                    configMap: {
                      name: "sfdchosts",
                    },
                    name: "sfdchosts",
                  },
                ] +
                certs_and_kubeconfig.kubeconfig_platform_volume +
                certs_and_kubeconfig.platform_cert_volume,
            },
            metadata: {
                labels: {
                    name: "node-controller",
                    apptype: "control",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "node-controller",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "node-controller",
        },
        name: "node-controller",
        namespace: "flowsnake",
    },
} else "SKIP"
