local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbflights = import "slbflights.jsonnet";

if configs.estate == "prd-sdc" then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-echo-server",
        } + configs.ownerLabel.slb,
        name: "slb-echo-server",
        namespace: "sam-system",
        annotations: {
            "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
        },
    },
    spec+: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-echo-server",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    slbconfigs.slb_config_volume,
                ]),
                containers: [
                    {
                        name: "slb-echo-server",
                        image: slbimages.hyperslb,
                        command: [
                            "/sdn/slb-echo-service",
                            "--serviceName=slb-echo-svc",
                            "--runAsServer",
                            "--servicePort=" + portconfigs.slb.slbEchoServicePort,
                            "--log_dir=" + slbconfigs.logsDir,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                        ]),
                    } + configs.ipAddressResourceRequest,
                ],
                nodeSelector: {
                    "slb-service": "slb-echo-server",
                },
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy(),
        },
    },
} else "SKIP"
