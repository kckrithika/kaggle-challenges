local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
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
                    slbconfigs.slb_volume,
                    slbconfigs.host_volume,
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
                            slbconfigs.slb_volume_mount,
                            slbconfigs.host_volume_mount,
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

