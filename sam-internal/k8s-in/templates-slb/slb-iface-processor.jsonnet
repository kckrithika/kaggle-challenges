local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
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
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                ],
                "containers": [
                    {
                        "name": "slb-iface-processor",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-iface-processor",
                            "--configDir="+slbconfigs.configDir,
                            "--period=5s",
                            "--marker="+slbconfigs.ipvsMarkerFile,
                            "--markerPeriod=10s",
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
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
