local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" then {
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
                    }
                ],
                "containers": [
                    {
                        "name": "slb-realsvrcfg",
                        "image": configs.slb_realsvrcfg,
                        "command":[
                            "/sdn/slb-realsvrcfg",
                            "--realServersDir=/host/var/slb/config",
                            "--period=5s",
                            "--netInterfaceName=eth0"
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
                ]
            }
        }
    }
} else "SKIP"

