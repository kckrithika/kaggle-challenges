local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" then {
    kind: "DaemonSet",
    spec: {
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
                        args: ["--birdsock", "/usr/local/var/run/bird.ctl",
                        "--birdconf", "/usr/local/etc/bird.conf",
                        "--ipamcsv", "/usr/local/sdc/conf/samInput.csv",
                        "--vaultkeypair", "/usr/local/sdc/SDCBird_keypair",
                        "--overrideBGPSecret", "",
                        "--funnelEndpoint", configs.funnelVIP],
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
            },
            metadata: {
                labels: {
                    name: "sdc-peering-agent",
                    apptype: "control",
                    daemonset: "true",
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdc-peering-agent",
        },
        name: "sdc-peering-agent",
    }
} else "SKIP"
