local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

// Turned off by default. Enable only when needed for a prod issue.
if false then configs.daemonSetBase("slb") {
    spec+: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: slbimages.hypersdn,
                        command: [
                            "/bin/bash",
                            # Add commands here.
                        ],
                        name: "slb-ops-adhoc",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                        },
                        volumeMounts: std.prune([
                            slbconfigs.slb_kern_log_volume_mount,
                            configs.config_volume_mount,
                        ]),
                    },
                ],
                volumes: std.prune([
                    slbconfigs.slb_kern_log_volume,
                    configs.config_volume("slb-ops-adhoc"),
                ]),
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy()
              + slbconfigs.slbEstateNodeSelector,
            metadata: {
                labels: {
                    app: "slb-ops-adhoc",
                    daemonset: "true",
                } + configs.ownerLabel.sam,
            },
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "25%",
            },
        },
    },
    metadata+: {
        labels: {
            name: "slb-ops-adhoc",
        } + configs.ownerLabel.slb,
        name: "slb-ops-adhoc",
        namespace: "sam-system",
    },
} else
    "SKIP"
