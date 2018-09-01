local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-nginx-reporter",
        } + configs.ownerLabel.slb,
        name: "slb-nginx-reporter",
        namespace: "sam-system",
        annotations: {
            "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
        },
    },
    spec+: {
        replicas: 1,
        template: {
            spec: {
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        name: "slb-nginx-reporter",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-nginx-reporter",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--hostnameOverride=$(NODE_NAME)",
                            "--k8sApiServer=",
                            "--namespace=sam-system",
                            "--log_dir=" + slbconfigs.logsDir,
                            ],
                        volumeMounts: configs.filter_empty([
                        configs.maddog_cert_volume_mount,
                        slbconfigs.slb_volume_mount,
                        slbconfigs.logs_volume_mount,
                        configs.cert_volume_mount,
                        configs.kube_config_volume_mount,
                        configs.sfdchosts_volume_mount,
                        ]),
                        env: [
                            slbconfigs.node_name_env,
                            configs.kube_config_env,
                        ],
                    },
                ],
            } + (
                if slbconfigs.isTestEstate then { nodeSelector: { pool: configs.estate } } else { nodeSelector: { pool: configs.kingdom + "-slb" } }
            ),
            metadata: {
                labels: {
                    name: "slb-nginx-reporter",
                    apptype: "monitoring",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
