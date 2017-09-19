local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-dns-register"
        },
        "name": "slb-dns-register"
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-dns-register"
                }
            },
            "spec": {
                "hostNetwork": true,
                "volumes": configs.cert_volumes + [
                    configs.cert_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                ],
                "containers": [
                    {
                        "name": "slb-dns-register-processor",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-dns-register",
                            "--path="+slbconfigs.configDir,
                            "--ddi="+slbconfigs.ddiService,
                            "--keyfile="+configs.keyFile,
                            "--certfile="+configs.certFile,
                            "--cafile="+configs.caFile,
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir
                        ],
                        "volumeMounts": configs.cert_volume_mounts + [
                            configs.cert_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ],
                    }
                ],
                "nodeSelector":{
                    "slb-dns-register": "true"
                }
            }
        }
    }
} else "SKIP"
