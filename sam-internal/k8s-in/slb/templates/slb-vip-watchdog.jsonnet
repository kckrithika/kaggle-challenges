local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" || configs.kingdom == "prd" || configs.kingdom == "frf" || configs.kingdom == "phx" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
            labels: {
                name: "slb-vip-watchdog",
            },
            name: "slb-vip-watchdog",
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
                   slbconfigs.slb_volume,
                   slbconfigs.logs_volume,
                   configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        name: "slb-vip-watchdog",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-vip-watchdog",
                            "--vipLoop=10",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--optOutNamespace=kne",
                            "--monitorFrequency=60s",
                            "--hostnameOverride=$(NODE_NAME)",
                            configs.sfdchosts_arg,
                            "--metricsEndpoint=" + configs.funnelVIP,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        env: [
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
                }
                + (
                    if configs.estate == "prd-sdc" || configs.kingdom == "prd" then {
                         "slb-dns-register": "true",
                    } else {
                         pool: configs.estate,
                    }
                ),
            },
            metadata: {
                labels: {
                    name: "slb-vip-watchdog",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
} else "SKIP"
