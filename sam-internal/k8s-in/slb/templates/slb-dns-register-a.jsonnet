local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-dns-register-a",
        },
        name: "slb-dns-register-a",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-dns-register-a",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        name: "slb-dns-register-a-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-dns-register",
                            "--path=" + slbconfigs.configDir,
                            "--ddi=" + slbconfigs.ddiService,
                            "--keyfile=" + configs.keyFile,
                            "--certfile=" + configs.certFile,
                            "--cafile=" + configs.caFile,
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                    },
                ],
                nodeSelector: {
                    "slb-dns-register-a": "true",
                },
            },
        },
    },
} else "SKIP"
