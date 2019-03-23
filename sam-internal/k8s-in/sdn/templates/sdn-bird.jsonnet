local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then configs.daemonSetBase("sdn") {
    spec+: {
        [if sdnimages.phase == "1" || sdnimages.phase == "2" then "minReadySeconds"]: 60,
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
                                    "/bird/sdn-bird-watcher",
                               ],
                            },
                            initialDelaySeconds: 5,
                            periodSeconds: 10,
                        },
                        volumeMounts: configs.filter_empty([
                            {
                                name: "conf",
                                mountPath: "/usr/local/etc",
                            },
                            {
                                name: "socket",
                                mountPath: "/usr/local/var/run",
                            },
                            sdnconfigs.sdn_logs_volume_mount,
                        ]),
                        env: [
                            {
                                name: "BIRD_CONF",
                                value: "/usr/local/etc/bird.conf",
                            },
                            {
                                name: "BIRD_SOCKET",
                                value: "/usr/local/var/run/bird.ctl",
                            },
                        ],
                    },
                ],
                volumes: configs.filter_empty([
                    {
                        name: "conf",
                        hostPath: {
                            path: "/etc/kubernetes/sdn",
                        },
                    },
                    {
                        name: "socket",
                        hostPath: {
                            path: "/etc/kubernetes/sdn",
                        },
                    },
                    sdnconfigs.sdn_logs_volume,
                ]),
            },
            metadata: {
                labels: {
                    name: "sdn-bird",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
        },
        [if sdnimages.phase == "1" || sdnimages.phase == "2" then "updateStrategy"]: {
            type: "RollingUpdate",
            rollingUpdate: {
            maxUnavailable: "15%",
            },
        },
    },
    metadata: {
        labels: {
            name: "sdn-bird",
        },
        name: "sdn-bird",
        namespace: "sam-system",
    },
} else "SKIP"
