local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
            "labels": {
                "name": "slb-vip-watchdog"
            },
            "name": "slb-vip-watchdog",
		    "annotations": {
			     "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n"
		    }
     },
    "spec": {
        replicas: 1,
        "template": {
            "spec": {
                "hostNetwork": true,
                "volumes": [
                   slbconfigs.slb_volume,
                   slbconfigs.host_volume,
                   slbconfigs.logs_volume,
                ],
                "containers": [
                    {
                        "name": "slb-vip-watchdog",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-vip-watchdog",
                            "--configDir="+slbconfigs.configDir,
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--sender="+configs.watchdog_emailsender,
                            "--recipient=slb@salesforce.com",
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--vipLoop=100",
                            "--log_dir="+slbconfigs.logsDir
                        ],
                        "volumeMounts": [
                            slbconfigs.slb_volume_mount,
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ],
                    }
                ],
                nodeSelector: {
                                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "slb-vip-watchdog",
                    apptype: "monitoring"
                }
            }
        }
    }
} else "SKIP"
