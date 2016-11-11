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
                           "--debug=true",
                           "--dockerregistry="+configs.registry,
                           "--funneladdr="+configs.funnelVIP,
                           "--v=3",
                           "--logtostderr=true",
                           "--k8sapiserver=http://localhost:8000",
                        ]
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                }
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
