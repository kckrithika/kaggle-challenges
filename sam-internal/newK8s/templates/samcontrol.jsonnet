{
local images = import "images.jsonnet",
local configs = import "config.jsonnet",
local estate = std.extVar("estate"),
    kind: "Deployment", 
    spec: {
        replicas: 1, 
        template: {
            spec: {
                hostNetwork: true, 
                containers: [
                    {

                        image: images.controller[estate],
                        name: "sam-controller", 
                        env: [
                            {
                                name: "DOCKERREGISTRY", 
                                value: configs.registry[estate] 
                            }, 
                            {
                                name: "FUNNELVIP", 
                                value: configs.funnelVIP[estate]
                            }
                        ]
                    }
                ]
            }, 
            metadata: {
                labels: {
                    name: "samcontrol", 
                    apptype: "control"
                }
            }
        }, 
        selector: {
            matchLabels: {
                name: "samcontrol"
            }
        }
    }, 
    apiVersion: "extensions/v1beta1", 
    metadata: {
        labels: {
            name: "samcontrol"
        }, 
        name: "samcontrol"
    }
}
