local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "DaemonSet",
    "metadata": {
        "labels": {
            "name": "slb-iface-processor"
        },
        "name": "slb-iface-processor"
    },
    "spec": {
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-iface-processor",
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
                        "name": "slb-iface-processor",
                        "image": configs.slb_iface_processor,
                        "command":[
                            "/sdn/slb-iface-processor",
                            "--configDir="+slbconfigs.configDir,
                            "--period=5s",
                            "--marker="+slbconfigs.ipvsMarkerFile,
                            "--markerPeriod=10s",
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
