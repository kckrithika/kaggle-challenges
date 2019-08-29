local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-estate-installer" };
local slbflights = import "slbflights.jsonnet";

// Free up docker ip addresses in sdc by running this pod as host-network in prd-sdc.
local useHostNetwork = (configs.estate == "prd-sdc");
local ipAddressResourceRequestIfNonHostNetwork = (if !useHostNetwork then configs.ipAddressResourceRequest else {});
local hostNetworkIfEnabled = (if useHostNetwork then { hostNetwork: true } else {});

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
                        name: "yum-gpg-config-volume",
                        hostPath: {
                            path: "/etc/pki/rpm-gpg",
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
                                name: "yum-gpg-config-volume",
                                mountPath: "/etc/pki/rpm-gpg",
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
                    } + ipAddressResourceRequestIfNonHostNetwork,
                ],
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy()
              + hostNetworkIfEnabled,
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
