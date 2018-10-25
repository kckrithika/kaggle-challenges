local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "sammadkub.jsonnet") + { templateFilename:: std.thisFile };

local certDirs = ["cert1"];

if configs.estate == "prd-samdev" then
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshot-producer-mtls-test",
        } + configs.ownerLabel.sam,
        annotations: {
            "madkub.sam.sfdc.net/allcerts":
                std.manifestJsonEx(
                    { certreqs: { role: "csc-sam.snapshot-producer" } } + madkub.madkubSamCertsAnnotation(certDirs), " "
),
            },
        name: "snapshoter",
        namespace: "csc-sam",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshoter",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshoter",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [configs.containerWithKubeConfigAndMadDog {
                    command: [
                        "/sam/snapshoter",
                        "--config=/config/snapshoter.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "--v=4",
                        "--alsologtostderr",
                    ],
                    volumeMounts+: [
                        configs.sfdchosts_volume_mount,
                        configs.config_volume_mount,
                        configs.cert_volume_mount,
                        ] + madkub.madkubSamCertVolumeMounts(certDirs),
                    livenessProbe: {
                        httpGet: {
                            path: "/",
                            port: 9095,
                        },
                        initialDelaySeconds: 20,
                        periodSeconds: 20,
                        timeoutSeconds: 20,
                    },
                    image: samimages.hypersam,
                    name: "snapshoter",
                }] + [madkub.madkubRefreshContainer(certDirs)],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("snapshoter"),
                    configs.maddog_cert_volume,
                ] + madkub.madkubSamCertVolumes(certDirs)
                  + madkub.madkubSamMadkubVolumes(),
                initContainers+: [
                    madkub.madkubInitContainer(certDirs),
                ],
                hostNetwork: true,
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
        },
    },
} else "SKIP"
