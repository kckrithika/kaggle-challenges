local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
            labels: {
                name: "slb-labels-checker",
            },
            name: "slb-labels-checker",
            namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            spec: {
                volumes: configs.filter_empty([
                   slbconfigs.slb_volume,
                   slbconfigs.logs_volume,
                   configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        name: "slb-labels-checker",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-labels-checker",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--labelValues=" + "slb-ipvs: 2, slb-nginx: 2, slb-dns: 1",
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                    },
                ],
                nodeSelector: {
                       pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "slb-labels-checker",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
} else "SKIP"
