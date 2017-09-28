local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-canary-passthrough-host-network"
        },
        "name": "slb-canary-passthrough-host-network",
    } + 
        if configs.estate == "prd-sdc" then { 
		    "annotations": {
			     "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"name\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n"
		    }
            } else {},
    "spec": {
        replicas: 2,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-canary-passthrough-host-network"
                }
            },
            "spec": {
                "hostNetwork": true,
                "volumes": [
                    slbconfigs.host_volume,
                    slbconfigs.logs_volume,
                ],
                "containers": [
                    {
                        "name": "slb-canary-passthrough-host-network",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-canary-passthrough-host-network",
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir,
                            "--ports="+portconfigs.slb.canaryServicePassthroughHostNetworkPort,
                        ],
                        "volumeMounts": [
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ],
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            }
        }
    }
} else "SKIP"
