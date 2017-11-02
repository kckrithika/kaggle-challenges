local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
            labels: {
                name: "slb-baboon",
            },
            name: "slb-baboon",
            namespace: "sam-system",
     },
    spec: {
        replicas: 1,
        template: {
            spec: {
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                ]),
                containers: [
                    {
                        name: "slb-baboon",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-baboon",
                            "--period=1h",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--slbPodLabel=" + slbconfigs.podLabelList,
                            "--k8sapiserver=",
                            "--namespace=sam-system",
                            "--log_dir=" + slbconfigs.logsDir,
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                        ]),
                        env: [
                           configs.kube_config_env,
                        ],
                        securityContext: {
                            privileged: true,
                        },
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "slb-baboon",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
} else "SKIP"
