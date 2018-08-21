local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                  securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                  securityContext: {
                    privileged: true,
                },
                        name: "k8s-event-processor",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/hypersam:20180322_001013.ce444308.dirty.mayankkuma-ltm3",
                        command: configs.filter_empty([
                            "/sam/k8s-event-processor",
                            "--v=5",
                            "--k8sapiserver=",
                            "--namespacesToSkip=sam-watchdog,legostore,sam-system,sf-store",
                            configs.sfdchosts_arg,
                        ]),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                            {
                                mountPath: "/etc/systemd",
                                name: "etcsystemd",
                                readOnly: true,
                            },
                            {
                                mountPath: "/usr/bin",
                                name: "usrbin",
                                readOnly: true,
                            },
                            {
                               mountPath: "/usr/lib64",
                                name: "usrlib64",
                                readOnly: true,
                            },
                        ],
                        env+: [
                            {
                                name: "SYSTEMD_IGNORE_CHROOT",
                                value: "yes",
                            },
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    {
                        hostPath: {
                            path: "/usr/lib64",
                        },
                        name: "usrlib64",
                    },
                    {
                        hostPath: {
                            path: "/usr/bin",
                        },
                        name: "usrbin",
                    },
                    {
                        hostPath: {
                            path: "/run/systemd",
                        },
                        name: "runsystemd",
                    },
                    {
                        hostPath: {
                            path: "/etc/systemd",
                        },
                        name: "etcsystemd",
                    },
                ],
                nodeSelector: {
                                  master: "true",
                              },
            },
            metadata: {
                labels: {
                    name: "k8s-event-processor",
                    apptype: "control",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "k8s-event-processor",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "k8s-event-processor",
        } + configs.ownerLabel.sam,
        name: "k8s-event-processor",
        namespace: "sam-system",
    },
} else "SKIP"
