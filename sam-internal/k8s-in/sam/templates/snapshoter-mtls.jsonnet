local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "sammadkub.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";
local utils = import "util_functions.jsonnet";

local certDirs = ["cert1"];

if samfeatureflags.kafkaProducer then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshot-producer-mtls-test",
        } + configs.ownerLabel.sam,
        name: "snapshot-producer",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshot-producer",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshot-producer",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
                annotations: {
                    "madkub.sam.sfdc.net/allcerts":
                    std.manifestJsonEx(
                {
                    certreqs:
                        [
                            { role: "sam-system.snapshot-producer" } + certReq
                            for certReq in madkub.madkubSamCertsAnnotation(certDirs).certreqs
                        ],
                }, " "
),
            },
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
configs.containerWithKubeConfigAndMadDog {
                    command: [
                        "/sam/snapshoter",
                        "--config=/config/snapshoter-mtls.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "--v=4",
                        "--alsologtostderr",
                    ],
                    volumeMounts+: [configs.config_volume_mount]
                        + (if !utils.is_pcn(configs.kingdom) then [configs.cert_volume_mount, configs.sfdchosts_volume_mount] else [])
                        + madkub.madkubSamCertVolumeMounts(certDirs),
                    image: samimages.hypersam,
                    name: "snapshot-producer",
                } + if configs.estate == "prd-sam" then {

                } else {
                    livenessProbe: {
                        httpGet: {
                            path: "/",
                            port: 9095,
                        },
                        # Initial delay for snapshot producer is set high
                        # in order to allow start-up while volume of resources is high
                        initialDelaySeconds: 600,
                        periodSeconds: 30,
                        timeoutSeconds: 30,
                        failureThreshold: 5,
                    },
                },
                ] + [madkub.madkubRefreshContainer(certDirs)],
                volumes+: [
                    configs.config_volume("snapshoter-mtls"),
                ] + (if !utils.is_pcn(configs.kingdom) then [configs.cert_volume, configs.sfdchosts_volume] else [])
                  + madkub.madkubSamCertVolumes(certDirs)
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
                                  echo "dummy"
|||,
                        ],
                        securityContext: {
                          runAsNonRoot: false,
                          runAsUser: 0,
                        },
                    volumeMounts+: [configs.config_volume_mount]
                        + (if !utils.is_pcn(configs.kingdom) then [configs.cert_volume_mount, configs.sfdchosts_volume_mount] else [])
                        + madkub.madkubSamCertVolumeMounts(certDirs),
                    },
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
