{
local images = import "images.jsonnet",
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
                                value: "mandm-funnel-sfz.data.sfdc.net"
                            }
                        ]
                    }, 
                    {
                        image: "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/mock-tnrp:thargrove-20160915_105447-fb609d7", 
                        volumeMounts: [
                            {
                                mountPath: "/manifests", 
                                name: "sfdc-volume"
                            }
                        ], 
                        name: "mock-tnrp", 
                        env: [
                            {
                                name: "FUNNELVIP", 
                                value: "mandm-funnel-sfz.data.sfdc.net"
                            }, 
                            {
                                valueFrom: {
                                    secretKeyRef: {
                                        name: "gittoken", 
                                        key: "token"
                                    }
                                }, 
                                name: "GIT_TOKEN"
                            }, 
                            {
                                valueFrom: {
                                    secretKeyRef: {
                                        name: "gittoken", 
                                        key: "username"
                                    }
                                }, 
                                name: "GIT_USER"
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
