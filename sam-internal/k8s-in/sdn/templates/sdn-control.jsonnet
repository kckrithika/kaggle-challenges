local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "sdn-control"
        },
        "name": "sdn-control",
        "namespace": "sam-system",
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "sdn-control"
                }
            },
            "spec": {
                hostNetwork: true,
                "containers": [
                    {
                        "name": "sdn-control",
                        "image": sdnimages.hypersdn,
                        "command":[
                            "/sdn/sdn-control-service",
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--port="+portconfigs.sdn.sdn_control_service,
                            "--charonAgentEndpoint="+configs.charonEndpoint,
                        ],
                        "env": [
                            {
                                "name": "KUBECONFIG",
                                "value": "/config/kubeconfig"
                            }
                        ],
                        "volumeMounts": [
                            {
                                "mountPath": "/data/certs",
                                "name": "certs"
                            },
                            {
                                "mountPath": "/config",
                                "name": "config"
                            }
                        ]
                    }
                ],
                "volumes": [
                    {
                        "hostPath": {
                            "path": "/data/certs"
                        },
                        "name": "certs"
                    },
                    {
                        "hostPath": {
                            "path": "/etc/kubernetes"
                        },
                        "name": "config"
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            }
        }
    }
} else "SKIP"
