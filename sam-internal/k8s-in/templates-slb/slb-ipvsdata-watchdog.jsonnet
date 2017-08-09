local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
            "labels": {
                "name": "slb-ipvsdata-watchdog"
            },
            "name": "slb-ipvsdata-watchdog",
            "annotations": {
                  "scheduler.alpha.kubernetes.io/affinity": "{\n  \"podAntiAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": [\n      {\n        \"labelSelector\": {\n          \"matchExpressions\": [\n            {\n              \"key\": \"name\",\n              \"operator\": \"In\",\n              \"values\": [\"slb-ipvs\"]\n            }\n          ]\n        },\n        \"topologyKey\": \"kubernetes.io/hostname\"\n     }\n    ]\n   }\n }\n"
            }
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
                    },
                    {
                        "name": "certs",
                        "hostPath": {
                            "path": "/data/certs",
                        }
                     },
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
                            "--connPort="+slbconfigs.ipvsDataConnPort,
                            "--retryPeriod=2m",
                            "--maxretries=2"
                        ],
                        "volumeMounts": [
                            {
                                "name": "var-slb-volume",
                                "mountPath": "/host/var/slb"
                            },
                            {
                                "name": "host-volume",
                                "mountPath": "/host"
                            },
                            {
                                "name": "certs",
                                "mountPath": "/data/certs"
                            },
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
