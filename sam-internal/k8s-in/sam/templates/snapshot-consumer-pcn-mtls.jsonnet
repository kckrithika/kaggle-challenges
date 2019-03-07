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
            name: "snapshot-consumer-pcn-mtls",
        } + configs.ownerLabel.sam,
        name: "snapshot-consumer-pcn-mtls",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshot-consumer-pcn-mtls",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshot-consumer-pcn-mtls",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
                annotations: {
                    "madkub.sam.sfdc.net/allcerts":
                    std.manifestJsonEx(
                {
                    certreqs:
                        [
                            # The PCN consumer will use the same principal as the prod consumer for simplicitiy sake
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
                        name: "snapshot-consumer-pcn-mtls",
                        image: samimages.hypersam,
                    command: [
                        "/sam/snapshotconsumer",
                        "--config=/config/snapshot-consumer-pcn-mtls.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "-v=3",
                    ],
                    volumeMounts+: [
                        configs.sfdchosts_volume_mount,
                        configs.config_volume_mount,
                        configs.cert_volume_mount,
                        {
                            mountPath: "/var/mysqlPwd",
                            name: "mysql-ssc-pcn",
                            readOnly: true,
                        },
                    ] + madkub.madkubSamCertVolumeMounts(certDirs),
                },
] + [madkub.madkubRefreshContainer(certDirs)],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("snapshot-consumer-pcn-mtls"),
                    {
                              name: "mysql-ssc-pcn",
                              secret: {
                                  defaultMode: 420,
                                  secretName: "mysql-ssc-pcn",
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
                                name: "mysql-passwords",
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
