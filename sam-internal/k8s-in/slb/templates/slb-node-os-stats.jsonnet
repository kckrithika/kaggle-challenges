local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-node-os-stats",
        },
        name: "slb-node-os-stats",
        namespace: "sam-system",
    },
    spec: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-node-os-stats",
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
                       name: "slb-node-os-stats",
                       image: slbimages.hypersdn,
                       command: [
                           "/sdn/slb-node-os-stats",
                           "--metricsEndpoint=" + configs.funnelVIP,
                           "--log_dir=" + slbconfigs.logsDir,
                       ],
                       volumeMounts: configs.filter_empty([
                           slbconfigs.slb_volume_mount,
                           slbconfigs.logs_volume_mount,
                       ]),
                       securityContext: {
                           privileged: true,
                       },
                    },
                ],
                nodeSelector: {
                    "slb-service": "slb-ipvs",
                },
            },
        },
    },
} else "SKIP"
