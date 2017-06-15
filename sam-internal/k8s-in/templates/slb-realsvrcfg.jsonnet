local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "DaemonSet",
    "metadata": {
        "labels": {
            "name": "slb-realsvrcfg"
        },
        "name": "slb-realsvrcfg"
    },
    "spec": {
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-realsvrcfg",
                    "apptype": "control",
                    "daemonset": "true"
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
                        "name": "host-volume",
                        "hostPath": {
                            "path": "/"
                         }
                    }
                 ],
                "containers": [
                    {
                        "name": "slb-realsvrcfg",
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
                ]
            }
        }
    }
} else "SKIP"

