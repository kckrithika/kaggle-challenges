local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "idc-samhello-deployment"
        },
        "name": "idc-samhello-deployment",
        "namespace": "idc"
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
                "containers": [
                    {
                        "name": "idc-samhello",
                        "image": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/ichakeres/samhello:idc-20170811b",
                        "ports": [
                            {
                            "containerPort": 9090
		            },
			],
                        "livenessProbe": {
                            "httpGet": {
                                "path": "/",
                                "port": 9090
                            },
                        },
		    },
                ],
            }
        }
    }
} else "SKIP"
