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
                  "scheduler.alpha.kubernetes.io/affinity": "{\n  \"podAntiAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": [\n      {\n        \"labelSelector\": {\n          \"matchExpressions\": [\n            {\n              \"key\": \"name\",\n              \"operator\": \"In\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx-config\"]\n            }\n          ]\n        },\n        \"topologyKey\": \"kubernetes.io/hostname\"\n     }\n    ]\n   }\n }\n"
            }
     },
    "spec": {
        replicas: 1,
        "template": {
            "spec": {
                "volumes": [
                   {
                       "name": "var-slb-volume",
                        "hostPath": {
                           "path": "/var/slb"
                        }
                   },
                   {
                       "name": "host-volume",
                       "hostPath": {
                           "path": "/"
                       }
                   }
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
                            "--vipLoop=100"
                        ],
                        "volumeMounts": [
                            {
                                "name": "var-slb-volume",
                                "mountPath": "/host/var/slb"
                            },
                            {
                                 "name": "host-volume",
                                 "mountPath": "/host"
                            }
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
