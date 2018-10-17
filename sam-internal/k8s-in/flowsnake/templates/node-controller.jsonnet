local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
local flag_fs_metric_labels = std.objectHas(flowsnake_images.feature_flags, "fs_metric_labels");

if flowsnakeconfig.node_controller_enabled then
{
    local label_node = self.spec.template.metadata.labels,
    kind: "Deployment",
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: label_node.name,
                apptype: label_node.apptype,
            },
        },
        template: {
            spec: {
                containers: [
                    {
                        name: "node-controller",
                        image: flowsnake_images.node_controller,
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
                } + if flag_fs_metric_labels then {
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "NodeController",
                } else {},
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
