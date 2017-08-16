local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" then {
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
                    {
                        "name": "var-slb-volume",
                        "hostPath": {
                            "path": "/var/slb"
                         }
                    },
                    {
                        "name": "dev-volume",
                        "hostPath": {
                            "path": "/dev"
                         }
                    },
                    {
                        "name": "host-volume",
                        "hostPath": {
                            "path": "/"
                         }
                    }
                ],
                "containers": [
                    {
                        "name": "slb-alpha",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-alpha-svc",
                            "--port=9008",
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            {
                                "name": "dev-volume",
                                "mountPath": "/dev"
                            },
                            {
                                "name": "host-volume",
                                "mountPath": "/host"
                            }
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
                    {
                        "name": "slb-realsvrcfg-internal",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-realsvrcfg",
                            "--configDir="+slbconfigs.configDir,
                            "--period=5s",
                            "--netInterfaceName=eth0"
                        ],
                        "volumeMounts": [
                            {
                                "name": "var-slb-volume",
                                "mountPath": "/host/var/slb"
                            },
                            {
                                "name": "host-volume",
                                "mountPath": "/host"
                            }
                         ],
                        "securityContext": {
                            "privileged": true
                        }
                    }
                ],
                "nodeSelector":{
                    "slb-service": "alpha"
                }
            }
        }
    }
} else "SKIP"
