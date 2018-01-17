local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-canary-creator",
        },
        name: "slb-canary-creator",
         namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-creator",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                ]),
                containers: [
                    {
                        name: "slb-canary-creator",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-canary-creator",
                            "--canaryImage=" + slbimages.hypersdn,
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--maxParallelism=1",
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.kube_config_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                    },
                ],
            },
        },
    },
} else "SKIP"
