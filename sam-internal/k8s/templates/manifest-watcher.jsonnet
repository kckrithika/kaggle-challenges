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
                        name: "manifest-watcher", 
                        image: configs.manifest_watcher,
                        command: [
                           "/sam/manifest-watcher",
                           "--funneladdr="+configs.funnelVIP,
                           "--v=2",
                           "--logtostderr=true",
                           "--disableCertsCheck=true",
                           "--tnrpArchiveEndpoint="+configs.tnrpArchiveEndpoint,
                         ],
                    } 
                ], 
                volumes: [
                    {
                        hostPath: {
                            path: "/manifests"
                        }, 
                        name: "sfdc-volume"
                    }
                ]
            }, 
            metadata: {
                labels: {
                    name: "manifest-watcher", 
                    apptype: "control"
                }
            }
        }, 
        selector: {
            matchLabels: {
                name: "manifest-watcher"
            }
        }
    }, 
    apiVersion: "extensions/v1beta1", 
    metadata: {
        labels: {
            name: "manifest-watcher"
        }, 
        name: "manifest-watcher"
    }
}
