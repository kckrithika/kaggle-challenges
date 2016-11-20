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
                            "-role=MASTER",
                            "-watchdogFrequency=5s",
                            "-timeout=2s",
                            "--funneladdr="+configs.funnelVIP,
                            "-rcImtEndpoint="+configs.rcImtEndpoint,
                            "-smtpServer="+configs.smtpServer,
                            "-sender=prabh.singh@salesforce.com",
                            "-recipient=sam@salesforce.com",
                            "-cc=prabh.singh@salesforce.com,cdebains@salesforce.com,adhoot@salesforce.com,thargrove@salesforce.com,pporwal@salesforce.com,mayank.kumar@salesforce.com,prahlad.joshi@salesforce.com,xiao.zhou@salesforce.com,cbatra@salesforce.com"
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
                    MASTER: "true",
                }
            }, 
            metadata: {
                labels: {
                    app: "watchdog-master", 
                    apptype: "monitoring",
                    daemonset: "true",
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
