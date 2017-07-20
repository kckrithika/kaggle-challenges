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
                "hostNetwork": true,
                "volumes": [
                     {
                        "name": "host-volume",
                        "hostPath": {
                            "path": "/"
                         }
                     },
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
                            "--configDir="+slbconfigs.configDir,
                            "--target=/host/var/slb/nginx/config",
                            "--netInterfaceName=eth0",
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            {
                                "name": "host-volume",
                                "mountPath": "/host"
                            },
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
