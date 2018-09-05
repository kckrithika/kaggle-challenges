local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-estate-installer",
        } + configs.ownerLabel.slb,
        name: "slb-estate-installer",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 4,
        template: {
            metadata: {
                labels: {
                    name: "slb-estate-installer",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
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
                    configs.kube_config_volume,
                ]),
                affinity: {
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [{
                                matchExpressions: [{
                                    key: "slb-service",
                                    operator: "In",
                                    values: ["slb-ipvs", "slb-nginx-b"],
                                }],
                            }],
                        },
                    },
                },
                containers: [
                    {
                        name: "slb-estate-installer",
                        image: slbimages.hypersdn,
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
                            configs.kube_config_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                        env: [
                            configs.kube_config_env,
                            {
                                name: "NODE_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "spec.nodeName",
                                    },
                                },
                            },
                        ],
                    },
                ],
            },
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
