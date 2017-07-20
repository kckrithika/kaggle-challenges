local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-nginx-config"
        },
        "name": "slb-nginx-config"
    },
    "spec": {
        replicas: 2,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-nginx-config"
                }
            },
            "spec": {
                "volumes": [
                     {
                        "name": "var-target-config-volume",
                        "hostPath": {
                            "path": "/var/slb/nginx/config"
                         }
                     },
                     {
                        "name": "var-config-volume",
                        "hostPath": {
                            "path": "/var/slb/config"
                        }
                    }
                ],
                "containers": [
                    {
                        "name": "slb-nginx-config",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-nginx-config",
                            "--path="+slbconfigs.configDir,
                            "--target=/host/var/slb/nginx/config",
                            "--netInterfaceName=eth0",
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            {
                                "name": "var-target-config-volume",
                                "mountPath": "/host/var/slb/nginx/config"
                            },
                            {
                                "name": "var-config-volume",
                                "mountPath": "/host/var/slb/config"
                            }
                        ],
                    }
                ],
                "nodeSelector":{
                    "service": "slb-nginx"
                }
            }
        }
    }
} else "SKIP"
