local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-ipvs"
        },
        "name": "slb-ipvs"
    },
    "spec": {
        replicas: 2,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-ipvs"
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
                        "name": "dev-volume",
                        "hostPath": {
                            "path": "/dev"
                         }
                    },
                    {
                        "name": "lib-modules-volume",
                        "hostPath": {
                            "path": "/lib/modules"
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
                        "name": "slb-ipvs-installer",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-ipvs-installer",
                            "--modules=/sdn",
                            "--host=/host",
                            "--marker=/host/var/slb/ipvs.marker",
                            "--period=5s",
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            {
                                "name": "dev-volume",
                                "mountPath": "/dev"
                            },
                            {
                                "name": "lib-modules-volume",
                                "mountPath": "/lib/modules"
                            },
                            {
                                "name": "host-volume",
                                "mountPath": "/host"
                            }
                        ],
                        "securityContext": {
                            "privileged": true,
                            "capabilities": {
                                "add": [
                                    "ALL"
                                ]
                            }
                        }
                    },

                    {
                        "name": "slb-ipvs-processor",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-ipvs-processor",
                            "--configDir="+slbconfigs.configDir,
                            "--marker="+slbconfigs.ipvsMarkerFile,
                            "--period=5s",
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
                            }
                        ],
                        "securityContext": {
                            "privileged": true
                        }
                    },

                    {
                       "name": "slb-ipvs-data",
                       "image": slbimages.hypersdn,
                       "command":[
                           "/sdn/slb-ipvs-data",
                           "--connPort="+portconfigs.slb.ipvsDataConnPort
                       ],
                       "volumeMounts": [
                           {
                               "name": "var-slb-volume",
                               "mountPath": "/host/var/slb"

                           }
                       ],
                       "securityContext": {
                           "privileged": true
                       }
                    }
                ],
                "nodeSelector":{
                    "slb-service": "slb-ipvs"
                }
            }
        }
    }
} else "SKIP"
