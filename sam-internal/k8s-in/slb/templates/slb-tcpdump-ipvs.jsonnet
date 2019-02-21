local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if slbconfigs.isSlbEstate && slbflights.slbTCPdumpEnabled then configs.daemonSetBase("slb") {
    spec+: {
        template: {
            spec: {
                containers: [
                    {
                        image: slbimages.hyperslb,
                        command: [
                            // Make sure that tcpdump.pollinterval is smaller than duration specified in the configmap
                            "--tcpdump.pollinterval=10m",
                        ],
                        name: "slb-tcpdump-ipvs",
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
                        volumeMounts: [
                            configs.config_volume_mount,
                        ],
                    },
                ],
                volumes: [
                    configs.config_volume("slb-tcpdump-ipvs"),
                ],
                nodeSelector: {
                    // Only need to run this on ipvs nodes.
                    "slb-service": "slb-ipvs",
                },
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy(),
            metadata: {
                labels: {
                    name: "slb-tcpdump-ipvs",
                    daemonset: "true",
                } + configs.ownerLabel.slb,
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
            name: "slb-tcpdump-ipvs",
        } + configs.ownerLabel.slb,
        name: "slb-tcpdump-ipvs",
        namespace: "sam-system",
    },
} else
    "SKIP"
