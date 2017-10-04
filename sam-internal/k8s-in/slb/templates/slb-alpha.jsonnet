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
	 "namespace": "sam-system",
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-alpha"
                },
		"namespace": "sam-system",
            },
            "spec": {
                "volumes": configs.filter_empty([
                    slbconfigs.slb_volume,
                    {
                        "name": "dev-volume",
                        "hostPath": {
                            "path": "/dev"
                         }
                    },
                    slbconfigs.host_volume,
                    slbconfigs.logs_volume,
                ]),
                "containers": [
                    {
                        "name": "slb-alpha",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-alpha-svc",
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir,
                             "--ports=9008",
                        ],
                        "volumeMounts": configs.filter_empty([
                            {
                                "name": "dev-volume",
                                "mountPath": "/dev"
                            },
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                        "securityContext": {
                            "privileged": true,
                            "capabilities": {
                                "add": [
                                    "ALL"
                                ]
                            }
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
