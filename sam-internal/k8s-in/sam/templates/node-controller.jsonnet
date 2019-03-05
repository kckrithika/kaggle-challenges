local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

# Only private PROD info is provided for node-controller currently
if samfeatureflags.estatessvc then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "node-controller",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/node-controller",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            configs.sfdchosts_arg,
                          ]
                        + (if samfeatureflags.ipAddressCapacityNodeResource then ["--sdn-subnet-file-path=/kubeconfig/sfdc-sdn-subnet.env", "--default-max-podip=25"] else []),),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                        ],
                        env+: [
                            {
                                name: "NODE_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "spec.nodeName",
                                    },
                                },
                            },
                        ],
                    } + configs.ipAddressResourceRequest,
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                ],
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "node-controller",
                    apptype: "control",
                } + configs.ownerLabel.sam,
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
        } + configs.ownerLabel.sam,
        name: "node-controller",
        namespace: "sam-system",
    },
} else "SKIP"
