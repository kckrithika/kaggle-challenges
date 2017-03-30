local configs = import "config.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-bird",
                        image: configs.sdn_bird,
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
                        name: "sdn-peering-agent",
                        image: configs.sdn_peering_agent,
                        command:[
                            "/sdn/sdn-peering-agent",
                            "--birdsock=/usr/local/var/run/bird.ctl",
                            "--birdconf=/usr/local/etc/bird.conf",
                            "--vaultkeypair=/usr/local/sdn/SDCBird_keypair",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "-keyFile=/data/certs/hostcert.key",
                            "-certFile=/data/certs/hostcert.crt",
                        ],
                        "livenessProbe": {
                            "httpGet": {
                               "path": "/",
                               "port": 9100
                            },
                            "initialDelaySeconds": 5,
                            "periodSeconds": 10
                        },
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
                                name: "sdn-vol",
                                mountPath: "/usr/local/sdn",
                                readOnly: true,
                            },
                            {
                                name: "certs",
                                "mountPath": "/data/certs",
                            },
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
                        name: "sdn-vol",
                        hostPath: {
                            path: "/usr/local/sdc"
                        }
                    },
                    {
                        name: "certs",
                        "hostPath": {
                            "path": "/data/certs"
                        }
                    },
                ],
            },
            metadata: {
                labels: {
                    name: "sdn-peering-agent",
                    apptype: "control",
                    daemonset: "true",
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-peering-agent",
        },
        name: "sdn-peering-agent",
    }
} else "SKIP"
