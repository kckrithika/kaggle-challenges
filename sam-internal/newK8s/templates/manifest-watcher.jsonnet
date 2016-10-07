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

                        image: images.manifest_watcher[estate],
                        volumeMounts: [
                            {
                                mountPath: "/manifests", 
                                name: "sfdc-volume"
                            }
                        ], 
                        name: "manifest-watcher", 
                        env: [
                            {
                                name: "FUNNELVIP", 
                                value: configs.funnelVIP[estate] 
                            }
                        ]
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
