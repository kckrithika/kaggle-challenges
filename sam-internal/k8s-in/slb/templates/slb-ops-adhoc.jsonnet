local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = import "slbconfig.jsonnet";

// mgrass: 2019-01-25: journald killer for issue discussed in https://computecloud.slack.com/archives/C4BM25SK0/p1548450935086900
if slbconfigs.isSlbEstate && slbflights.slbJournaldKillerEnabled then configs.daemonSetBase("slb") {
    spec+: {
        template: {
            spec: {
                hostNetwork: true,
                // Need host PID to be able to discover processes running on the host (e.g., systemd-journald).
                hostPID: true,
                containers: [
                    {
                        image: slbimages.hypersdn,
                        command: [
                            "/bin/bash",
                            "/config/slb-journald-killer.sh",
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
                            {
                                name: "host-etc-volume",
                                mountPath: "/hostetc",
                            },
                            configs.config_volume_mount,
                        ]),
                    },
                ],
                volumes: std.prune([
                    {
                        name: "host-etc-volume",
                        hostPath: {
                            path: "/etc",
                        },
                    },
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
