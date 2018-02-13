local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
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
                            (if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then sdnconfigs.sdn_logs_volume_mount else {}),
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
                    (if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then sdnconfigs.sdn_logs_volume else {}),
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
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-bird",
        },
        name: "sdn-bird",
        namespace: "sam-system",
    },
} else "SKIP"
