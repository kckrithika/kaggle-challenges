local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-nginx-data-watchdog",
        } + configs.ownerLabel.slb,
        name: "slb-nginx-data-watchdog",
        namespace: "sam-system",
        annotations: {
            "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
        },
    },
    spec: {
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
                        name: "slb-nginx-data-watchdog",
                        image: slbimages.hypersdn,
                        command: [
                            "sdn/slb/slb-nginx-data-watchdog",
                            "--namespace=sam-system",
                            configs.sfdchosts_arg,
                            "--k8sapiserver=",
                            "--connPort=" + portconfigs.slb.nginxDataConnPort,
                            "--monitorFrequency=180s",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--hostnameOverride=$(NODE_NAME)",
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
                     name: "slb-nginx-data-watchdog",
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
