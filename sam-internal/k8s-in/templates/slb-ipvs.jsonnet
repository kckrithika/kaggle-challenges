local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" then {
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
                        "image": configs.slb_ipvs,
                        "command":[
                            "/sdn/slb-ipvs-installer",
                            "--modules=/sdn",
                            "--host=/host",
                            "--mode=continuous",
                            "--target=/host/var/slb",
                            "--period=5s"
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
                        "image": configs.slb_ipvs,
                        "command":[
                            "/sdn/slb-ipvs-processor",
                            "--configDir=/host/var/slb/config",
                            "--marker=/host/var/slb/ipvs.installed",
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
                    }

                ],
                "nodeSelector":{
                    "service": "slb-ipvs"
                }
            }
        }
    }
} else "SKIP"
