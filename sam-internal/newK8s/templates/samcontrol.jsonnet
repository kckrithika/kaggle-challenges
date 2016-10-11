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
                        name: "sam-controller", 
                        image: configs.controller,
                        command:[
                           "/sam/sam-controller",
                           "---debug=true",
                           "--dockerregistry="+configs.registry,
                           "--funneladdr="+configs.funnelVIP,
                           "--v=2",
                           "--logtostderr=true"
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
