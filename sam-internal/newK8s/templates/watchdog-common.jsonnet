{
local images = import "images.jsonnet",
local estate = std.extVar("estate"),
    kind: "DaemonSet", 
    spec: {
        template: {
            spec: {
                hostNetwork: true, 
                containers: [
                    {
                        image: images.watchdog_common[estate],
                        command: [
                            "/sam/watchdog", 
                            "-role=COMMON"
                        ], 
                        name: "watchdog", 
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
                nodeSelector: {
                    COMMON: 'true'
                }
            }, 
            metadata: {
                labels: {
                    app: "watchdog-common", 
                    apptype: "monitoring"
                }
            }
        }
    }, 
    apiVersion: "extensions/v1beta1", 
    metadata: {
        labels: {
            name: "watchdog-common"
        }, 
        name: "watchdog-common"
    }
}
