local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "sammadkub.jsonnet") + { templateFilename:: std.thisFile };

local certDirs = ["cert1"];
if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshotconsumer-prd-mtls",
        } + configs.ownerLabel.sam,
        name: "snapshotconsumer-prd-mtls",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshotconsumer-prd-mtls",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshotconsumer-prd-mtls",
                } + configs.ownerLabel.sam,
                annotations: {
                            "madkub.sam.sfdc.net/allcerts":
                            std.manifestJsonEx(
                        {
                            certreqs:
                                [
                                    { role: "sam-system.snapshotconsumer-prd-mtls" } + certReq
                                    for certReq in madkub.madkubSamCertsAnnotation(certDirs).certreqs
                                ],
                        }, " "
                    ),
                },
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
configs.containerWithKubeConfigAndMadDog {
                    name: "snapshotconsumer-prd-mtls",
                    image: samimages.hypersam,
                    command: [
                        "/sam/snapshotconsumer",
                        "--config=/config/snapshotconsumer-prd-mtls.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "-v=3",
                    ],
                    volumeMounts+: [
                        configs.sfdchosts_volume_mount,
                        configs.config_volume_mount,
                        configs.cert_volume_mount,
                        {
                            mountPath: "/var/mysqlPwd",
                            name: "mysql-ssc-prd",
                            readOnly: true,
                        },
                        ] + madkub.madkubSamCertVolumeMounts(certDirs),
                },
                ] + [madkub.madkubRefreshContainer(certDirs)],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    {
                        secret: {
                            secretName: "mysql-ssc-prd",
                        },
                        name: "mysql-ssc-prd",
                    },
                    configs.config_volume("snapshotconsumer-prd-mtls"),
                ] + madkub.madkubSamCertVolumes(certDirs)
                  + madkub.madkubSamMadkubVolumes(),
                initContainers+: [
                    madkub.madkubInitContainer(certDirs),
                ],
                hostNetwork: true,
            },
        },
    },
} else "SKIP"
