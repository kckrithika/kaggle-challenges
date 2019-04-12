local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local name = "crd-watcher";
local samreleases = import "samreleases.json";

{
        kind: "Deployment",
        spec: {
            replicas: 1,
            template: {
                spec: configs.specWithKubeConfigAndMadDog {
                    hostNetwork: true,
                    containers: [
                        configs.containerWithKubeConfigAndMadDog {
                            name: name,
                            image: samimages.hypersam,
                            command: configs.filter_empty([
                                "/sam/manifest-watcher",
                                "--funnelEndpoint=" + configs.funnelVIP,
                                "--v=2",
                                "--logtostderr=true",
                                "--config=/config/tempmanifestwatcher.json",
                                "--syntheticEndpoint=http://$(WATCHDOG_SYNTHETIC_SERVICE_SERVICE_HOST):9090/tnrp/content_repo/0/archive",
                                configs.sfdchosts_arg,
                                "--etcdSetDisabled=true",
                                "--etcdGetDisabled=true",
                            ]) + (
                                if configs.kingdom != "mvp" then
                                [] else [
                                   "--crdSetEnabled=true",
                                   "--crdGetEnabled=true",
                                ]
                            ),
                            volumeMounts+: configs.filter_empty([
                                configs.sfdchosts_volume_mount,
                                configs.config_volume_mount,
                                configs.cert_volume_mount,
                            ]),
                            ports: [
                                    {
                                        containerPort: 21553,
                                    },
                                ],
                        } + configs.containerInPCN
                        + {
                             livenessProbe: {
                                  httpGet: {
                                      path: "/healthz",
                                      port: 21553,
                                  },
                                  initialDelaySeconds: 60,
                                  periodSeconds: 30,
                              },
                          },
                    ],
                    volumes+: configs.filter_empty([
                        configs.cert_volume,
                        configs.sfdchosts_volume,
                        {
                            hostPath: {
                                path: "/manifests",
                            },
                            name: "sfdc-volume",
                        },
                        configs.config_volume(name),
                    ]),
                    nodeSelector: {
                                  } +
                                  if !utils.is_production(configs.kingdom) then {
                                      master: "true",
                                  } else {
                                      pool: configs.estate,
                                  },
                } + configs.serviceAccount,
                metadata: {
                    labels: {
                        name: name,
                        apptype: "control",
                    } + configs.ownerLabel.sam,
                    namespace: "sam-system",
                },
            },
            selector: {
                matchLabels: {
                    name: name,
                },
            },
        },
        apiVersion: "extensions/v1beta1",
        metadata: {
            labels: {
                name: name,
            } + configs.ownerLabel.sam
            + configs.pcnEnableLabel,
            name: name,
        },
    }
