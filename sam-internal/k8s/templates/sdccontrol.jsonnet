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
                        name: "sdc-bird",
                        image: configs.registry + "/sdc-bird:pporwal-201701171227",
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
                        image: configs.registry + "/sdc-peering-conf:nkatta-201701200445",
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
                                name: "sdc-vol",
                                mountPath: "/usr/local/sdc",
                                readOnly: true,
                            },
                        ],
                    },
                    {
                        name: "sdc-metrics",
                        image: configs.registry + "/sdc-metrics:vkarnati-201701191232",
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
                        name: "sdc-vol",
                        hostPath: {
                            path: "/usr/local/sdc"
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
