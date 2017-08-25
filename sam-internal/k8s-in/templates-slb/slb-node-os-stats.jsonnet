local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

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
        replicas: 2,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-node-os-stats"
                }
            },
            "spec": {
                "hostNetwork": true,
                "volumes": [
                    slbconfigs.slb_volume,
                    {
                        "name": "dev-volume",
                        "hostPath": {
                            "path": "/dev"
                         }
                    },
                    slbconfigs.host_volume,
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
                           slbconfigs.slb_volume_mount,
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