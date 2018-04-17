local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
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
                   configs.kube_config_volume,
                   configs.cert_volume,
                   configs.maddog_cert_volume,
                ]),
                containers: [
                    {
                        name: "slb-labels-checker",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-labels-checker",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--hostnameOverride=$(NODE_NAME)",
                            "--metricsEndpoint=" + configs.funnelVIP,
                        ] + if configs.estate == "prd-sam" then [
                            "--labelValues=slb-ipvs:3,slb-nginx-b:3",
                        ] else if configs.estate == "prd-sdc" then [
                            "--labelValues=slb-ipvs:2,slb-nginx-b:2",
                        ] else [
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                            {
                               name: "NODE_NAME",
                               valueFrom: {
                                  fieldRef: {
                                     fieldPath: "spec.nodeName",
                                  },
                               },
                            },
                        ],
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
    } + if slbimages.phase == "1" || slbimages.phase == "2" then {
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    } else {},
} else "SKIP"
