local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-config-data",
        },
        name: "slb-config-data",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-config-data",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                 ]),
                containers: [
                        {
                            name: "slb-config-data",
                            image: slbimages.hypersdn,
                            command: [
                                "/sdn/slb-config-data",
                                "--slbDir=" + slbconfigs.slbDir,
                                "--port=" + portconfigs.slb.slbConfigDataPort,
                            ],
                            volumeMounts: configs.filter_empty([
                                slbconfigs.slb_volume_mount,
                             ]),
                        },
                ],
             },
        },
    },
} else "SKIP"
