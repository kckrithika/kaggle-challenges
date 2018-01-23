local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-dns-register",
        },
        name: "slb-dns-register",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-dns-register",
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
                ] + if configs.estate == "prd-sdc" then [
                                                      configs.sfdchosts_volume,
                                                   ] else []),
                containers: [
                    {
                        name: "slb-dns-register-processor",
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
                        ] + if configs.estate == "prd-sdc" then [
                                                                              configs.sfdchosts_arg,
                                                                           ] else [],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ] + if configs.estate == "prd-sdc" then [
                                                                              configs.sfdchosts_volume_mount,
                                                                           ] else []),
                    },
                ],
                nodeSelector: {
                    "slb-dns-register": "true",
                },
            },
        },
    },
} else "SKIP"
