local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-alpha"
        },
        "name": "slb-alpha",
        "annotations": {
              "scheduler.alpha.kubernetes.io/affinity": "{\n  \"podAntiAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": [\n      {\n        \"labelSelector\": {\n          \"matchExpressions\": [\n            {\n              \"key\": \"name\",\n              \"operator\": \"In\",\n              \"values\": [\"slb-ipvs\"]\n            }\n          ]\n        },\n        \"topologyKey\": \"kubernetes.io/hostname\"\n     }\n    ]\n   }\n }\n"
        }
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-alpha"
                }
            },
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
                        "name": "slb-alpha",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-alpha-svc",
                            "--port=9008",
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir
                        ],
                        "volumeMounts": [
                            {
                                "name": "dev-volume",
                                "mountPath": "/dev"
                            },
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ],
                        "securityContext": {
                            "privileged": true,
                            "capabilities": {
                                "add": [
                                    "ALL"
                                ]
                            }
                        }
                    },
                ],
                "nodeSelector":{
                    "slb-service": "alpha"
                }
            }
        }
    }
} else "SKIP"
