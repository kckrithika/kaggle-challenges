#IDC started from ../templates-sdb/slb-nginx-config.jsonnet

local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-samtest" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "idc-centos-config"
        },
        "name": "idc-centos-config"
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "idc-centos-config"
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
                            "path": "/var/idc/centos/config"
                         }
                     },
                     {
                        "name": "var-config-volume",
                        "hostPath": {
                            "path": "/var/idc/config"
                        }
                    }
                ],
                "containers": [
                    {
                        "name": "idc-centos-config",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-centos-config",
                            "--configDir="+slbconfigs.configDir,
                            "--target=/host/var/idc/centos/config",
                            "--netInterfaceName=eth0",
#                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            {
                                "name": "host-volume",
                                "mountPath": "/host"
                            },
                            {
                                "name": "var-target-config-volume",
                                "mountPath": "/host/var/idc/centos/config"
                            },
                            {
                                "name": "var-config-volume",
                                "mountPath": "/host/var/idc/config"
                            }
                        ],
#                        "securityContext": {
#                            "privileged": true
#                        }
                     }
                ],
                "nodeSelector":{
                    "idc-service": "idc-centos"
                }
            }
        }
    }
} else "SKIP"
