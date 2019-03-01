local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

std.prune({
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "samapp-controller",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/samapp-controller",
                            "--v=3",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--logtostderr=true",
                            (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "vpod" then "--ciNamespaceConfigFile=/ci/ci-namespaces.json" else {}),
                            "--config=/config/samapp-controller-config.json",
                            (if configs.kingdom == "vpod" then "--resyncPeriod=2m" else {}),
                            configs.sfdchosts_arg,
                        ]) + (if samfeatureflags.maddogforsamapps then [
                                  # Kept here because of the use of the envvar. Keep in sync with the config.
                                  "--madkubEndpoint=" + "https://$(MADKUBSERVER_SERVICE_HOST):32007",
                              ] else []),
                        volumeMounts+: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "vpod" then configs.ci_namespaces_volume_mount else {}),
                            configs.cert_volume_mount,
                        ]),
                          ports: [
                                  {
                                      containerPort: 21548,
                                  },
                              ],
                    }
                    + configs.containerInPCN
                    + {
                        livenessProbe: {
                             httpGet: {
                                 path: "/healthz",
                                 port: 21548,
                             },
                             initialDelaySeconds: 30,
                             periodSeconds: 5,
                         },
                     },
                ],
                volumes+: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "vpod" then configs.ci_namespaces_volume else {}),
                    configs.config_volume("samapp-controller"),
                ]),
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            } + configs.serviceAccount,
            metadata: {
                labels: {
                    name: "samappcontroller",
                    apptype: "control",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "samappcontroller",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samappcontroller",
        } + configs.ownerLabel.sam
        + configs.pcnEnableLabel,
        name: "samappcontroller",
        [if configs.kingdom == "vpod" then "namespace"]: "sam-system",
    },
})
