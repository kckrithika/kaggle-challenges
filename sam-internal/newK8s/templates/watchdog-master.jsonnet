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
                        image: images.watchdog_master[estate],
                        command: [
                            "/sam/watchdog", 
                            "-role=MASTER"
                        ], 
                        name: "watchdog", 
                        resources: {
                            requests: {
                                cpu: "0.5", 
                                memory: "300Mi"
                            }, 
                            limits: {
                                cpu: "0.5", 
                                memory: "300Mi"
                            }
                        }
                    }
                ], 
                nodeSelector: {
                    MASTER: "true"
                }
            }, 
            metadata: {
                labels: {
                    app: "watchdog-master", 
                    apptype: "monitoring"
                }
            }
        }
    }, 
    apiVersion: "extensions/v1beta1", 
    metadata: {
        labels: {
            name: "watchdog-master"
        }, 
        name: "watchdog-master"
    }
}
