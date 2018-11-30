local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "sammadkub.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

local certDirs = ["cert1"];

if samfeatureflags.kafkaConsumer then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshot-consumer-prod-mtls",
        } + configs.ownerLabel.sam,
        name: "snapshot-consumer-prod-mtls",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshot-consumer-prod-mtls",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshot-consumer-prod-mtls",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
                annotations: {
                    "madkub.sam.sfdc.net/allcerts":
                    std.manifestJsonEx(
                {
                    certreqs:
                        [
                            { role: "sam-system.snapshot-consumer-prod-mtls" } + certReq
                            for certReq in madkub.madkubSamCertsAnnotation(certDirs).certreqs
                        ],
                }, " "
),
            },
            },
            spec: configs.specWithKubeConfigAndMadDog {
                dnsPolicy: "ClusterFirst",
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "snapshot-consumer-prod-mtls",
                        image: samimages.hypersam,
                    command: [
                        "/sam/snapshotconsumer",
                        "--config=/config/snapshot-consumer-prod-mtls.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "-v=3",
                    ],
                    volumeMounts+: [
                        configs.sfdchosts_volume_mount,
                        configs.config_volume_mount,
                        configs.cert_volume_mount,
                        {
                            mountPath: "/var/mysqlPwd",
                            name: "mysql-passwords",
                            readOnly: true,
                        },
                    ] + madkub.madkubSamCertVolumeMounts(certDirs),
                },
] + [madkub.madkubRefreshContainer(certDirs)],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("snapshot-consumer-prod-mtls"),
                    {
                              name: "mysql-passwords",
                              secret: {
                                  defaultMode: 420,
                                  secretName: "mysql-passwords",
                               },
                            },
                ] + madkub.madkubSamCertVolumes(certDirs)
                  + madkub.madkubSamMadkubVolumes(),
                initContainers+: [
                    madkub.madkubInitContainer(certDirs),
                    {
                        image: samimages.permissionInitContainer,
                        name: "permissionsetterinitcontainer",
                        imagePullPolicy: "Always",
                        command: [
                                  "bash",
                                  "-c",
|||
                                  set -ex
                                  chmod 775 -R /data/certs && chown -R 7447:7447 /data/certs 
                                  chmod 775 -R /cert1 && chown -R 7447:7447 /cert1
|||,
                        ],
                        securityContext: {
                          runAsNonRoot: false,
                          runAsUser: 0,
                        },
                        volumeMounts: [
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                            {
                                mountPath: "/var/mysqlPwd",
                                name: "mysql-ssc-prod",
                                readOnly: true,
                            },
                        ] + madkub.madkubSamCertVolumeMounts(certDirs),
                    },
                ],
                        nodeSelector: if configs.kingdom == "prd" then {
                          master: "true",
                      } else {
                          pool: configs.estate,
                      },
            },
        },
    },
} else "SKIP"
