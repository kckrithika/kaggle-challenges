local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";

{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-hairpin-setter",
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-hairpin-setter",
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "sys-mount",
                                mountPath: "/sys/devices/virtual/net",
                            },
                            sdnconfigs.sdn_logs_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    },
                ],
                volumes: configs.filter_empty([
                    {
                        name: "sys-mount",
                        hostPath: {
                            path: "/sys/devices/virtual/net",
                        },
                    },
                    sdnconfigs.sdn_logs_volume,
                ]),
            },
            metadata: {
                labels: {
                    name: "sdn-hairpin-setter",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-hairpin-setter",
        },
        name: "sdn-hairpin-setter",
        namespace: "sam-system",
    },
}
