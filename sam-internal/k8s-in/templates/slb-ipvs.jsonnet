local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-ipvs"
        },
        "name": "slb-ipvs"
    },
    "spec": {
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
                       "mountPath": "/var/slb"
                   },
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
                       "mountPath": "/"
                   }
                 ],

                 "containers": [
                    {
                        "name": "slb-ipvs-installer",
                        "image": configs.slb_ipvs,
                        "command":[
                            "/sdn/slb-ipvs-installer",
                            "--modules=/sdn",
                            "--host=/host"
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
                        "name": "slb-ipvs-agent",
                        "image": configs.slb_ipvs,
                        "command":[
                            "/sdn/slb-ipvs-agent",
                            "--path=/host/var/slb"
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

                ]
            }
        }
    }
} else "SKIP"
