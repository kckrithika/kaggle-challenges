local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-realsvrcfg",
        },
        name: "slb-realsvrcfg",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-realsvrcfg",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.sbin_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                 ]),
                containers: [
                    {
                        name: "slb-realsvrcfg",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-realsvrcfg",
                            "--configDir=" + slbconfigs.configDir,
                            "--period=5s",
                            "--netInterfaceName=eth0",
                            "--log_dir=" + slbconfigs.logsDir,
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.sbin_volume_mount,
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
