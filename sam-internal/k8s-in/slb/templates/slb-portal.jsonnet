local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-portal"
        },
        "name": "slb-portal",
    } + 
        if configs.estate == "prd-sdc" then { 
		    "annotations": {
			     "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"name\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n"
		    }
            } else {},
    "spec": {
        replicas: 1,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-portal"
                }
            },
            "spec": {
                "hostNetwork": true,
                "volumes": [
                    slbconfigs.slb_volume,
                    {
                        "name": "dev-volume",
                        "hostPath": {
                            "path": "/dev"
                         }
                    },
                    slbconfigs.host_volume,
                ],
                "containers": [
                    {
                       "name": "slb-portal",
                       "image": slbimages.hypersdn,
                       "command":[
                           "/sdn/slb-portal",
                           "--configDir="+slbconfigs.configDir,
                           "--templatePath="+slbconfigs.slbPortalTemplatePath,
                           "--port="+portconfigs.slb.slbPortalServicePort
                       ],
                       "volumeMounts": [
                           slbconfigs.slb_volume_mount,
                       ]
                    }
                ],
                nodeSelector:{
                    pool: configs.estate
                }
            }
        }
    }
} else "SKIP"
