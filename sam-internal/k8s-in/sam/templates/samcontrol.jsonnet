local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if configs.estate != "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "sam-controller",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/sam-controller",
                            "--dockerregistry=" + configs.registry,
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--v=3",
                            "--logtostderr=true",
                            "--config=/config/samcontrol.json",
                            configs.sfdchosts_arg,
                        ]) + (if samfeatureflags.maddogforsamapps then [
                                  # Kept here because of the use of the envvar. Keep in sync with the config.
                                  "-maddogMadkubEndpoint=" + "https://$(MADKUBSERVER_SERVICE_HOST):32007",
                              ] else []),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ],

                        livenessProbe: {
                                 httpGet: {
                                     path: "/healthz",
                                     port: 22545,
                                 },
                                 initialDelaySeconds: 30,
                                 periodSeconds: 5,
                        },
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("samcontrol"),
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
                    name: "samcontrol",
                    apptype: "control",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "samcontrol",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samcontrol",
        } + configs.ownerLabel.sam,
        name: "samcontrol",
    },
} else "SKIP"
