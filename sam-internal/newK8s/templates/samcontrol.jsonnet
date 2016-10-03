{
local images = import "images.jsonnet",
local estate = std.extVar("estate"),
    "kind": "Deployment", 
    "spec": {
        "replicas": 1, 
        "template": {
            "spec": {
                "hostNetwork": true, 
                "containers": [
                    {

                        "image": images.controller[estate],
                        "name": "sam-controller", 
                        "env": [
                            {
                                "name": "DOCKERREGISTRY", 
                                "value": "shared0-samcontrol1-1-prd.eng.sfdc.net:5000"
                            }, 
                            {
                                "name": "FUNNELVIP", 
                                "value": "mandm-funnel-sfz.data.sfdc.net"
                            }
                        ]
                    }
                ]
            }, 
            "metadata": {
                "labels": {
                    "name": "samcontrol", 
                    "apptype": "control"
                }
            }
        }, 
        "selector": {
            "matchLabels": {
                "name": "samcontrol"
            }
        }
    }, 
    "apiVersion": "extensions/v1beta1", 
    "metadata": {
        "labels": {
            "name": "samcontrol"
        }, 
        "name": "samcontrol"
    }
}
