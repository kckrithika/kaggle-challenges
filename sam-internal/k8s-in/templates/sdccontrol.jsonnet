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
                        image: configs.sdc_bird,
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
                        env: [
                            {
                                name: "BIRD_CONF",
                                value: "/usr/local/etc/bird.conf"
                            },
                            {
                                name: "BIRD_SOCKET",
                                value: "/usr/local/var/run/bird.ctl"
                            },
                        ],
                    },
                    {
                        name: "sdc-peering-agent",
                        image: configs.sdc_peering_agent,
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
                        args: ["--birdsock", "/usr/local/var/run/bird.ctl", "--birdconf", "/usr/local/etc/bird.conf", "--ipamcsv", "/usr/local/sdc/conf/samInput.csv"],
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
