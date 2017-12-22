local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sdc" then {
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
                            path: "/etc/kubernetes",
                        },
                    },
                    {
                        name: "socket",
                        hostPath: {
                            path: "/etc/kubernetes",
                        },
                    },
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
