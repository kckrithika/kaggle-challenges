local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-iface-processor",
        },
        name: "slb-iface-processor",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-iface-processor",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        name: "slb-iface-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-iface-processor",
                            "--configDir=" + slbconfigs.configDir,
                            "--period=5s",
                            "--marker=" + slbconfigs.ipvsMarkerFile,
                            "--markerPeriod=10s",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    },
                ],
            },
        },
    },
} else "SKIP"
