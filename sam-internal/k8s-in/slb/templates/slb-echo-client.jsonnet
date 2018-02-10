local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-echo-client",
        },
        name: "slb-echo-client",
         namespace: "sam-system",
                    annotations: {
                             "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n
           \"requiredDuringSchedulingIgnoredDuringExecution\": {\n
           \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\":
           [\n            {\n              \"key\": \"slb-service\",\n
           \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\",
           \"slb-nginx\", \"slb-echo-server\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
                    },
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-echo-client",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                ]),
                containers: [
                    {
                        name: "slb-echo-client",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-echo-service",
                            "--serviceName=slb-echo-svc",
                            "--dataSize=1073741824",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                        ]),
                    },
                ],
                nodeSelector: {
                  pool: configs.estate,
                },
            },
        },
    },
} else "SKIP"
