{
local configs = import "config.jsonnet",

    kind: "Deployment", 
    spec: {
        replicas: 1, 
        template: {
            spec: {
                hostNetwork: true, 
                containers: [
                    {

                        image: configs.controller,
                        name: "sam-controller", 
                        env: [
                            {
                                name: "DOCKERREGISTRY", 
                                value: configs.registry 
                            }, 
                            {
                                name: "FUNNELVIP", 
                                value: configs.funnelVIP
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
