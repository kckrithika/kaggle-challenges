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
                            "-rcImtEndpoint=http://ops0-orch1-1-prd.eng.sfdc.net:8080/v1/bark",
                            "-smtpServer=rd1-mta1-4-sfm.ops.sfdc.net:25",
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
                    MASTER: "true"
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
