local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "idc-centos-config"
        },
        "name": "idc-centos-config"
    },
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "idc-centos-config"
                }
            },
            "spec": {
                "containers": [
                    {
                        "name": "idc-centos-config",
                        "image": ops0-artifactrepo1-0-prd.data.sfdc.net/docker-dev-base/cops/centos:7.2017.08
                    }
                ],
                "nodeSelector":{
                    "idc-service": "idc-centos"
                }
            }
        }
    }
} else "SKIP"
