local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-bravo"
        },
        "name": "slb-bravo"
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-bravo"
                },
            } + 
            if configs.estate == "prd-sdc" then { 
		    "annotations": {
			     "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"name\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n"
		    }
            } else {},
            "spec": {
                "volumes": [
                    slbconfigs.slb_volume,
                    {
                        "name": "dev-volume",
                        "hostPath": {
                            "path": "/dev"
                         }
                    },
                    slbconfigs.host_volume,
                    slbconfigs.logs_volume,
                ],
                "containers": [
                    {
                        "name": "slb-bravo",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-bravo-svc",
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir,
                            "--ports=9090,9091,9092",
                        ],
                        "volumeMounts": [
                            {
                                "name": "dev-volume",
                                "mountPath": "/dev"
                            },
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
