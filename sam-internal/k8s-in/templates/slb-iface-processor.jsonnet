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
                        "hostPath": {
                            "path": "/var/slb"
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
                        "name": "slb-iface-agent",
                        "image": configs.slb_iface_agent,
                        "command":[
                            "/sdn/slb-iface-agent",
                            "--configDir=/host/var/slb/config",
                            "--period=5s",
                            "--marker=/host/var/slb/ipvs.marker",
                            "--markerPeriod=10s",
                            "--bin=/sdn",
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            {
                                "name": "var-slb-volume",
                                "mountPath": "/host/var/slb"
                            },
                            {
                                "name": "var-config-volume",
                                "mountPath": "/host/var/slb/config"
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
