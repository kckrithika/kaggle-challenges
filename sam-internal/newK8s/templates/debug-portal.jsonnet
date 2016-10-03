{
local images = import "images.jsonnet",
local estate = std.extVar("estate"),
    kind:"DaemonSet", 
    spec: {
        template: {
            spec: {
                hostNetwork: true, 
                containers: [
                    {
                        livenessProbe: {
                            httpGet: {
                                path: "/", 
                                port: 47360
                            }
                        }, 
                        name: "debug-portal", 
                        image: images.debug_portal[estate],
                        volumeMounts: [
                            {
                                mountPath: "/var/run/", 
                                name: "varrun"
                            }
                        ], 
                        ports: [
                            {
                                containerPort: 47360, 
                                name: "debug-portal"
                            }
                        ], 
                        resources: {
                            requests: {
                                cpu: '0.5', 
                                memory: "300Mi"
                            }, 
                            limits: {
                                cpu: '0.5', 
                                memory: "300Mi"
                            }
                        }
                    }
                ], 
                volumes: [
                    {
                        hostPath: {
                            path: "/var/run/"
                        }, 
                        name: "varrun"
                    }
                ]
            }, 
            metadata: {
                labels: {
                    app: "debug-portal", 
                    apptype: "debugging"
                }
            }
        }
    }, 
    apiVersion: "extensions/v1beta1", 
    metadata: {
        labels: {
            name: "debug-portal"
        }, 
        name: "debug-portal"
    }
}
