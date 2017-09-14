local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-bird",
                        image: sdnimages.bird,
                        livenessProbe: {
                            exec: {
                               command: [
                                    "/bird/sdn-bird-watcher"
                               ]
                            },
                            initialDelaySeconds: 5,
                            periodSeconds: 10
                        },
                        volumeMounts: configs.cert_volume_mounts + [
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
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-peering-agent",
                            "--birdsock=/usr/local/var/run/bird.ctl",
                            "--birdconf=/usr/local/etc/bird.conf",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--keyfile=/data/certs/hostcert.key",
                            "--certfile=/data/certs/hostcert.crt",
                            "--bgpPasswordFile=/data/secrets/sambgppassword",
                            "--livenessProbePort="+portconfigs.sdn.sdn_peering_agent,
                            
                        ]
                        + (if configs.kingdom == "prd" then [ "--controlEstate="+configs.estate ] else [ "--controlEndpoint="+configs.estate ])
                        + (if configs.estate == "prd-sdc" then [ "--controlEndpoint=http://10.254.219.222:9108" ] else []),
                        "livenessProbe": {
                            "httpGet": {
                               "path": "/liveness-probe",
                               "port": portconfigs.sdn.sdn_peering_agent
                            },
                            "initialDelaySeconds": 5,
                            "timeoutSeconds": 5,
                            "periodSeconds": 20
                        },
                        volumeMounts: configs.cert_volume_mounts + [
                            {
                                name: "conf",
                                mountPath: "/usr/local/etc",
                            },
                            {
                                name: "socket",
                                mountPath: "/usr/local/var/run",
                            },
                            {
                                name: "certs",
                                mountPath: "/data/certs",
                            },
                            {
                                name: "secrets",
                                mountPath: "/data/secrets",
                                readOnly: true,
                            },
                        ],
                    },
                ],
                volumes: configs.cert_volumes + [
                    {
                        name: "conf",
                        emptyDir: {},
                    },
                    {
                        name: "socket",
                        emptyDir: {},
                    },
                    {
                        name: "certs",
                        hostPath: {
                            path: "/data/certs",
                        }
                    },
                    {
                        name: "secrets",
                        secret: {
                            defaultMode: 256,
                            secretName: "sdn",
                        },
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
