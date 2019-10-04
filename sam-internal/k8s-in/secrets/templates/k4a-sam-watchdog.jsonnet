local configs = import "config.jsonnet";
local secretsconfigs = import "secretsconfig.libsonnet";
local secretsimages = (import "secretsimages.libsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if secretsconfigs.k4aSamWdEnabled then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "k4a-sam-watchdog",
        } + configs.ownerLabel.secrets,
        name: "k4a-sam-watchdog",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        revisionHistoryLimit: 2,
        selector: {
            matchLabels: {
                name: "k4a-sam-watchdog",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "monitoring",
                    name: "k4a-sam-watchdog",
                } + configs.ownerLabel.secrets,
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        command: [
                                     "/sam/watchdog",
                                     "-role=SYNTHETIC",
                                     "-watchdogFrequency=180s",
                                     "-funnelEndpoint=" + configs.funnelVIP,
                                     "-config=/config/watchdog.json",
                                     configs.sfdchosts_arg,
                                     "-timeout=2s",
                                     "-caFile=" + configs.caFile,
                                     "-keyFile=" + configs.keyFile,
                                     "-certFile=" + configs.certFile,
                                     "-imageName=" + secretsimages.k4aSamWatchdog,
                                     "-enableStatelessChecks=false",
                                     "-enableK4aChecks=true",
                                 ],
                        image: secretsimages.k4aSamWatchdog,
                        name: "k4a-sam-watchdog",
                        volumeMounts+: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            {
                                mountPath: "/test",
                                name: "test",
                            },
                            {
                                mountPath: "/_output",
                                name: "output",
                            },
                            configs.cert_volume_mount,
                        ]),
                    },
                ],
                hostNetwork: true,
                nodeSelector: {
                              } +
                              if !utils.is_production(configs.kingdom) then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },

                volumes+: std.prune([
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    {
                        hostPath: {
                            path: "/manifests",
                        },
                        name: "sfdc-volume",
                    },
                    {
                        emptyDir: {},
                        name: "test",
                    },
                    {
                        emptyDir: {},
                        name: "output",
                    },
                ]),
            },
        },
    },
} else "SKIP"
