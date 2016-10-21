{
local configs = import "config.jsonnet",

    kind: "DaemonSet", 
    spec: {
        template: {
            spec: {
                containers: [
                    {
                        image: configs.slam_agent,
                        command: ["/sam/slam-agent"],
                        volumeMounts: [
                            {
                                mountPath: "/var/run/", 
                                name: "varrun"
                            }, 
                            {
                                readOnly: true, 
                                mountPath: "/var/log/", 
                                name: "varlog"
                            }
                        ], 
                        name: "slam-agent", 
                        livenessProbe: {
                            initialDelaySeconds: 15, 
                            httpGet: {
                                path: "/health", 
                                port: 30108
                            }, 
                            timeoutSeconds: 1
                        }, 
                        ports: [
                            {
                                containerPort: 30108, 
                                name: "slam-agent", 
                                hostPort: 30108
                            }
                        ]
                    }
                ], 
                volumes: [
                    {
                        hostPath: {
                            path: "/var/run/"
                        }, 
                        name: "varrun"
                    }, 
                    {
                        hostPath: {
                            path: "/var/log"
                        }, 
                        name: "varlog"
                    }
                ]
            }, 
            metadata: {
                labels: {
                    app: "slam-agent", 
                    apptype: "logagent",
                    daemonset: "true",
                }
            }
        }
    }, 
    apiVersion: "extensions/v1beta1", 
    metadata: {
        labels: {
            name: "slam-agent"
        }, 
        name: "slam-agent"
    }
}
