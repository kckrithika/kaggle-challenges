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

                        image: configs.manifest_watcher,
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
                                value: configs.funnelVIP 
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
