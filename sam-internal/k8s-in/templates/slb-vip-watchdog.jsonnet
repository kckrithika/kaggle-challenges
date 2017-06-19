local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
            "labels": {
                "name": "slb-vip-watchdog"
            },
            "name": "slb-vip-watchdog"
     },
    "spec": {
        replicas: 1,
        "template": {
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
                            "--alertThreshold=300s"
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

