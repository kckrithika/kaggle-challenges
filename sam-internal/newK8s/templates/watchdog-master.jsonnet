{
local configs = import "config.jsonnet",

    kind: "DaemonSet", 
    spec: {
        template: {
            spec: {
                hostNetwork: true, 
                containers: [
                    {
                        image: configs.watchdog_master,
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
