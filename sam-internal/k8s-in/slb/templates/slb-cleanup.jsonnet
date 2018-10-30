local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = import "slbsharedservices.jsonnet";
local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate then configs.daemonSetBase("slb") {
    metadata: {
        labels: {
            name: "slb-cleanup",
        } + configs.ownerLabel.slb,
        name: "slb-cleanup",
        namespace: "sam-system",
    },
    spec+: {
        template: {
            metadata: {
                labels: {
                    name: "slb-cleanup",
                    apptype: "control",
                    daemonset: "true",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    slbconfigs.cleanup_logs_volume,
                ]),
                containers: [
                    slbshared.slbLogCleanup,
                ],
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy(),
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "20%",
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
