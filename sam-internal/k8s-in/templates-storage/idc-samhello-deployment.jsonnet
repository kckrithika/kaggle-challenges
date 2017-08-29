local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "idc-samhello"
        },
        "name": "idc-samhello-deployment",
        "namespace": "sam-system"
    },
    "spec": {
        "replicas": 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "idc-samhello"
                }
            },
            "spec": {
                "hostNetwork": true,
                "containers": [
                    {
                        "name": "idc-samhello",
                        "image": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/ichakeres/samhello:idc-20170828a",
                        "ports": [
                            {
                            "containerPort": 9078
		                    },
			            ],
                        "livenessProbe": {
                            "httpGet": {
                                "path": "/",
                                "port": 9078
                            },
                        },
                    },
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            }
        }
    }
} else "SKIP"
