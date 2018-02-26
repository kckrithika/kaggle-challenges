local configs = import "config.jsonnet";
local slbports = import "slbports.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-node-api",
        },
        name: "slb-node-api",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-node-api",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                 ]),
                containers: [
                        {
                            name: "slb-node-api",
                            image: slbimages.hypersdn,
                            command: [
                                "/sdn/slb-node-api",
                                "--port=" + slbports.slb.slbNodeApiPort,
                                "--configDir=" + slbconfigs.configDir,
                            ],
                            volumeMounts: configs.filter_empty([
                                slbconfigs.slb_volume_mount,
                                slbconfigs.logs_volume_mount,
                             ]),
                        },
                ],
             },
        },
    },
} else "SKIP"
