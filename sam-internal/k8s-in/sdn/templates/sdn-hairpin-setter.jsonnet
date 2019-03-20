local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

configs.daemonSetBase("sdn") {
    spec+: {
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
                            sdnconfigs.alsoLogToStdErrArg,
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
                } + (if configs.kingdom != "prd" &&
                        configs.kingdom != "xrd" then
                        configs.ownerLabel.sdn else {}),
                namespace: "sam-system",
            },
        },
        [if sdnimages.phase == "1" then "updateStrategy"]: {
            type: "RollingUpdate",
            rollingUpdate: {
            maxUnavailable: "25%",
            },
        },
    },
    metadata: {
        labels: {
            name: "sdn-hairpin-setter",
        },
        name: "sdn-hairpin-setter",
        namespace: "sam-system",
    },
}
