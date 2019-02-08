local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = import "slbconfig.jsonnet";

local script = "/config/slb-journald-killer-journald-hash.sh";

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
                        image: slbimages.hyperslb,
                        command: [
                            "/bin/bash",
                            script,
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
                            {
                                name: "host-systemd-volume",
                                mountPath: "/host-systemd",
                            },
                        ]),
                        env: [
                            // mgrass: 01/28/2019 - Inject an inert environment variable to trigger a deployment after the script (configmap) change
                            // to disable killing of journald.
                            {
                                name: "IMMUTABLE_DEPLOYMENTS_ARE_GOOD",
                                value: "true",
                            },
                        ],
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
                    {
                        name: "host-systemd-volume",
                        hostPath: {
                            path: "/usr/lib/systemd",
                        },
                    },
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
