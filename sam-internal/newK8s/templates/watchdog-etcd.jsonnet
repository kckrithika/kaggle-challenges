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
                        image: images.watchdog_etcd[estate],
                        command: [
                            "/sam/watchdog", 
                            "-role=ETCD"
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
                    ETCD: 'true'
                }
            }, 
            metadata: {
                labels: {
                    app: "watchdog-etcd", 
                    apptype: "monitoring"
                }
            }
        }
    }, 
    apiVersion: "extensions/v1beta1", 
    metadata: {
        labels: {
            name: "watchdog-etcd"
        }, 
        name: "watchdog-etcd"
    }
}
