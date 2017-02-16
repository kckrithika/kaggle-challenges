{
local configs = import "config.jsonnet",
    
    kind: "DaemonSet", 
    spec: {
        template: {
            spec: {
                hostNetwork: true, 
                containers: [
                    {
                        image: configs.watchdog,
                        command: [
                            "/sam/watchdog", 
                            "-role=COMMON",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
                            "-timeout=2s",
                            "-funnelEndpoint="+configs.funnelVIP,
                            "-rcImtEndpoint="+configs.rcImtEndpoint,
                            "-smtpServer="+configs.smtpServer,
                            "-sender="+configs.watchdog_emailsender,
                            "-recipient="+configs.watchdog_emailrec,
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
            }, 
            metadata: {
                labels: {
                    app: "watchdog-common", 
                    apptype: "monitoring",
                    daemonset: "true",
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
