local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-canary-passthrough-tls"
        },
        "name": "slb-canary-passthrough-tls"
    },
    "spec": {
        replicas: 2,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-canary-passthrough-tls"
                }
            },
            "spec": {
                "volumes": configs.filter_empty([
                    slbconfigs.host_volume,
                    slbconfigs.logs_volume,
                ]),
                "containers": [
                    {
                        "name": "slb-canary-passthrough-tls",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-canary-passthrough-tls",
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir,
                            "--ports="+portconfigs.slb.canaryServicePassthroughTlsPort,
                        ],
                        "volumeMounts": configs.filter_empty([
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            }
        }
    }
} else "SKIP"