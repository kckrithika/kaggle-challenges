local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-node-os-stats"
        },
        "name": "slb-node-os-stats"
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-node-os-stats"
                }
            },
            "spec": {
                "hostNetwork": true,
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
                       "name": "slb-node-os-stats",
                       "image": slbimages.hypersdn,
                       "command":[
                           "/sdn/slb-node-os-stats",
                           "--metricsEndpoint="+configs.funnelVIP
                       ],
                       "volumeMounts": [
                           {
                               "name": "var-slb-volume",
                               "mountPath": "/host/var/slb"

                           }
                       ],
                       "securityContext": {
                           "privileged": true
                       }
                    }
                ],
                "nodeSelector":{
                    "slb-service": "slb-ipvs"
                }
            }
        }
    }
} else "SKIP"