local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "DaemonSet",
    "metadata": {
        "labels": {
            "name": "slb-iface-agent"
        },
        "name": "slb-iface-agent"
    },
    "spec": {
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-iface-agent",
                    "apptype": "control",
                    "daemonset": "true"
                }
            },
            "spec": {
                "hostNetwork": true,
                "volumes": [
                    {
                        "name": "var-slb-volume",
                        "mountPath": "/var/slb"
                    }
                ],
                "containers": [
                    {
                        "name": "slb-iface-agent",
                        "image": configs.slb_iface_agent,
                        "command":[
                            "/sdn/slb-iface-agent",
                            "--path=/host/var/slb",
                            "--period=2s",
                            "--bin=/sdn"
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
