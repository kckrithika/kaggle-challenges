local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-canary-proxy-tcp"
        },
        "name": "slb-canary-proxy-tcp",
	"namespace": "sam-system",
    },
    "spec": {
        replicas: 2,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-canary-proxy-tcp"
                },
		"namespace": "sam-system",
            },
            "spec": {
                "volumes": [
                    slbconfigs.host_volume,
                    slbconfigs.logs_volume,
                ],
                "containers": [
                    {
                        "name": "slb-canary-proxy-tcp",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-canary-proxy-tcp",
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir,
                            "--ports="+portconfigs.slb.canaryServiceProxyTcpPort,
                        ],
                        "volumeMounts": [
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ],
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            }
        }
    }
} else "SKIP"
