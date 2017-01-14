local configs = import "config.jsonnet";
if configs.estate == "prd-sdc" then {
    kind: "Deployment",
    spec: {
        replicas: 3,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdc-peering-agent",
                        image: configs.registry + "/sdc-peering-agent:latest",
                        volumeMounts: [
                            {
                                name: "conf",
                                mountPath: "/usr/local/etc",
                            },
                            {
                                name: "socket",
                                mountPath: "/usr/local/var/run",
                            },
                        ],
                    },
                    {
                        name: "sdc-peering-conf",
                        image: configs.registry + "/sdc-peering-conf:latest",
                        volumeMounts: [
                            {
                                name: "conf",
                                mountPath: "/usr/local/etc",
                            },
                            {
                                name: "socket",
                                mountPath: "/usr/local/var/run",
                            },
                            {
                                name: "bird-csv",
                                mountPath: "/root/src/sdcc/conf",
                            },
                        ],
                    },
                    {
                        name: "sdc-metrics",
                        image: configs.registry + "/sdc-metrics:latest",
                        command:[
                           "/sdc-metrics/publisher",
                           "--funnelEndpoint="+configs.funnelVIP,
                        ],
                    },
                ],
                volumes: [
                    {
                        name: "conf",
                        emptyDir: {},
                    },
                    {
                        name: "socket",
                        emptyDir: {},
                    },
                    {
                        name: "bird-csv",
                        hostPath: {
                            path: "/usr/local/sdc_bird_conf"
                        }
                    },
                ],
                nodeSelector: {
                    pool: configs.estate
                }
            },
            metadata: {
                labels: {
                    name: "sdc-peering-agent",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "sdc-peering-agent"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdccontrol"
        },
        name: "sdccontrol"
    }
} else "SKIP"
