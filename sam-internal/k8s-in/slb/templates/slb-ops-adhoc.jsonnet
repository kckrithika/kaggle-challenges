local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

// Turned off by default. Enable only when needed for a prod issue.

// Gigantor celery logs are spamming the root disk partition (`/`) in fra. The root partition only has 100 GB, and is critical for
// services to function. Enabling this script in fra to clean those logs.
if slbflights.cleanupGigantorLogs then configs.daemonSetBase("slb") {
    spec+: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: slbimages.hypersdn,
                        command: [
                            "/bin/bash",
                            "/config/slb-cleanup-logs.sh",
                            "/var/log/celery-gigantor",
                            "3600",
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
