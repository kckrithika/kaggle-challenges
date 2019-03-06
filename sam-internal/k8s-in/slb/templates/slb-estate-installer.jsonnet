local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-estate-installer" };
local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate then configs.daemonSetBase("slb") {
    metadata: {
        labels: {
            name: "slb-estate-installer",
        },
        name: "slb-estate-installer",
        namespace: "sam-system",
    },
    spec+: {
        template: {
            metadata: {
                labels: {
                    name: "slb-estate-installer",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    {
                        name: "yum-estates-repo-config-volume",
                        hostPath: {
                            path: "/etc/yum.repos.d",
                        },
                    },
                    {
                        name: "yum-estates-repo-volume",
                        hostPath: {
                            path: "/opt/estates",
                        },
                    },
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                ]),
                affinity: {
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [
                                {
                                    matchExpressions: [
                                        {
                                            key: "pool",
                                            operator: "In",
                                            values: [slbconfigs.slbEstate],
                                        },
                                    ],
                                },
                            ],
                        },
                    },
                },
                containers: [
                    {
                        name: "slb-estate-installer",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-estate-installer",
                            "--log_dir=" + slbconfigs.logsDir,
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "yum-estates-repo-config-volume",
                                mountPath: "/etc/yum.repos.d",
                            },
                            {
                                name: "yum-estates-repo-volume",
                                mountPath: "/opt/estates",
                            },
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                        env: [
                            configs.kube_config_env,
                            slbconfigs.node_name_env,
                        ],
                    } + configs.ipAddressResourceRequest,
                ],
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy(),
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
