local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "idc-centos-deployment"
        },
        "name": "idc-centos-deployment",
        "namespace": "idc"
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "idc-centos"
                }
            },
            "spec": {
                "containers": [
                    {
                        "name": "idc-centos",
                        "image": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-dev-base/cops/centos:7.2017.08",
                    }
                ],
            }
        }
    }
} else "SKIP"
