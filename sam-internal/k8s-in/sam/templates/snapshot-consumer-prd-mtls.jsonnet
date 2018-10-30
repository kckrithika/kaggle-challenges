local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "sammadkub.jsonnet") + { templateFilename:: std.thisFile };

local certDirs = ["cert1"];
if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshot-consumer-prd-mtls-test",
        } + configs.ownerLabel.sam,
        name: "snapshot-consumer-prd-mtls",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshot-consumer-prd-mtls",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshot-consumer-prd-mtls",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
                annotations: {
                    "madkub.sam.sfdc.net/allcerts":
                    std.manifestJsonEx(
                {
                    certreqs:
                        [
                            { role: "sam-system.snapshot-consumer-prd-mtls" } + certReq
                            for certReq in madkub.madkubSamCertsAnnotation(certDirs).certreqs
                        ],
                }, " "
),
            },
            },
            spec: configs.specWithKubeConfigAndMadDog {
                dnsPolicy: "ClusterFirst",
                containers: [{
                    name: "snapshot-consumer-prd-mtls",
                    image: samimages.hypersam,
                    command: [
                        "/sam/snapshotconsumer",
                        "--config=/config/snapshot-consumer-prd-mtls.json",
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
                }] +
                [madkub.madkubRefreshContainer(certDirs)],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("snapshot-consumer-prd-mtls"),
                            {
                              name: "mysql-ssc-prd",
                              secret: {
                                  defaultMode: 420,
                                  secretName: "mysql-ssc-prd",
                                },
                            },
                ] + madkub.madkubSamCertVolumes(certDirs)
                  + madkub.madkubSamMadkubVolumes(),
                initContainers+: [
                    madkub.madkubInitContainer(certDirs),
                ],
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
