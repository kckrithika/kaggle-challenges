local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-dns-register"
        },
        "name": "slb-dns-register"
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-dns-register"
                }
            },
            "spec": {
                "hostNetwork": true,
                "volumes": [
                    {
                        "name": "certs",
                        "hostPath": {
                            "path": "/data/certs",
                        }
                     },
                     {
                        "name": "var-config-volume",
                        "hostPath": {
                            "path": "/var/slb/config"
                        }
                    }
                ],
                "containers": [
                    {
                        "name": "slb-dns-register-processor",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-dns-register",
                            "--path="+slbconfigs.configDir,
                            "--ddi="+slbconfigs.ddiService,
                            "--keyfile="+configs.keyFile,
                            "--certfile="+configs.certFile,
                            "--cafile="+configs.caFile,
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                             {
                                "name": "certs",
                                "mountPath": "/data/certs"
                             },
                             {
                                "name": "var-config-volume",
                                "mountPath": "/host/var/slb/config"
                            }
                        ],
                    }
                ],
                "nodeSelector":{
                    "service": "slb-ipvs"
                }
            }
        }
    }
} else "SKIP"
