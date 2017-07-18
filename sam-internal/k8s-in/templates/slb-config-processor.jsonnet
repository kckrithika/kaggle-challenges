local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "DaemonSet",
    "metadata": {
        "labels": {
            "name": "slb-config-processor"
        },
        "name": "slb-config-processor"
    },
    "spec": {
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-config-processor",
                    "apptype": "control",
                    "daemonset": "true"
                }
            },
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
                        "name": "var-config-volume",
                        "hostPath": {
                        "path": "/var/slb/config"
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
                     {
                        "name": "config",
                        "hostPath": {
                            "path": "/etc/kubernetes",
                         }
                    }
                 ],
                "containers": [
                    {
                        "name": "slb-config-processor",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-config-processor",
                            "--configDir="+slbconfigs.configDir,
                            "--period=15s",
                            "--namespace=sam-system",
                            "--podstatus=running",
                            "--subnet="+slbconfigs.subnet,
                            "--k8sapiserver="+configs.k8sapiserver,
                            "--serviceList="+slbconfigs.serviceList,
                            "--vipList="+slbconfigs.vipList,
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            {
                                "name": "var-slb-volume",
                                "mountPath": "/host/var/slb"
                            },
                            {
                                "name": "var-config-volume",
                                "mountPath": "/host/var/slb/config"
                            },
                            {
                                "name": "host-volume",
                                "mountPath": "/host"
                            },
                            {
                                "name": "certs",
                                "mountPath": "/data/certs"
                            },
                            {
                               "name": "config",
                               "mountPath": "/config"
                            }
                         ],
                         env: [
                            {
                                "name": "KUBECONFIG",
                                "value": configs.configPath
                            }
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
