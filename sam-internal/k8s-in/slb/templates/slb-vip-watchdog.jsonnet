local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
            labels: {
                       name: "slb-vip-watchdog",
            },
            name: "slb-vip-watchdog",
            namespace: "sam-system",
            annotations: {} +
              (if configs.kingdom == "prd" then {
                  "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx-a\",\"slb-nginx-b\"]\n            },\n            {\n              \"key\": \"illumio\",\n              \"operator\": \"NotIn\",\n              \"values\":[\"a\", \"b\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
              } else {
                                    "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx-a\",\"slb-nginx-b\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
              }),
    },
    spec: {
        replicas: 1,
        template: {
            spec: {}
            + (
             if slbconfigs.slbInProdKingdom then {
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
                            "--httpTimeout=5s",
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
                   pool: configs.estate,
                },
             } else {
                 volumes: configs.filter_empty([
                        slbconfigs.slb_volume,
                        slbconfigs.logs_volume,
                        configs.sfdchosts_volume,
                 ]),
                 affinity: {
                    podAntiAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: [{
                        labelSelector: {
                           matchExpressions: [{
                             key: "name",
                             operator: "In",
                             values: [
                                 "slb-ipvs",
                                 "slb-ipvs-a",
                                 "slb-ipvs-b",
                                 "slb-nginx-config-b",
                                 "slb-nginx-config-a",
                             ],
                         }],
                                },
                        topologyKey: "kubernetes.io/hostname",
                       }],
                    },
                 },
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
                                 "--httpTimeout=5s",
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
                   nodeSelector: {}
                + (
                    if configs.estate == "prd-sam" then {
                         pool: configs.kingdom + "-slb",
                    } else {
                         pool: configs.estate,
                    }
                ),
             }
            ),
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
