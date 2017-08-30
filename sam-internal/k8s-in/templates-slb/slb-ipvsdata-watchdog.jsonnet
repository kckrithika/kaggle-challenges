local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
            "labels": {
                "name": "slb-ipvsdata-watchdog"
            },
            "name": "slb-ipvsdata-watchdog",
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
                    configs.cert_volume,
                    configs.kube_config_volume,
                 ],
                "containers": [
                    {
                        "name": "slb-ipvsdata-watchdog",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-ipvsdata-watchdog",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--sender="+configs.watchdog_emailsender,
                            "--recipient=slb@salesforce.com",
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--k8sapiserver="+configs.k8sapiserver,
                            "--connPort="+portconfigs.slb.ipvsDataConnPort,
                            "--retryPeriod=2m",
                            "--maxretries=2",
                            "--log_dir="+slbconfigs.logsDir
                        ],
                        "volumeMounts": [
                            slbconfigs.slb_volume_mount,
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                         ],
                         env: [
                            configs.kube_config_env,
                        ],
                        "securityContext": {
                           "privileged": true
                        }
                    }
                ],
                nodeSelector: {
                                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "slb-ipvsdata-watchdog",
                    apptype: "monitoring"
                }
            }
        }
    }
} else "SKIP"
