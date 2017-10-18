local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-echo-server",
        },
        name: "slb-echo-server",
         namespace: "sam-system",
                    annotations: {
                             "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
                    },
    },
    spec: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-echo-server",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    {
                        name: "dev-volume",
                        hostPath: {
                            path: "/dev",
                         },
                    },
                    slbconfigs.host_volume,
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-echo-server",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-echo-service",
                            "--serviceName=slb-echo-svc",
                            "--runAsServer",
                            "--servicePort=" + portconfigs.slb.slbEchoServicePort,
                            "--log_dir=" + slbconfigs.logsDir,
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "dev-volume",
                                mountPath: "/dev",
                            },
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                        securityContext: {
                            capabilities: {
                                add: [
                                    "ALL",
                                ],
                            },
                        },
                    },
                ],
                nodeSelector: {
                  "slb-service": "slb-echo-server",
                },
            },
        },
    },
} else "SKIP"
