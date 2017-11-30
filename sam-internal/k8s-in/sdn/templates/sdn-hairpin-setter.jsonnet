local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.kingdom == "prd" || configs.kingdom == "yhu" || configs.kingdom == "dfw" then {
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
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "sys-mount",
                                mountPath: "/sys",
                            },
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    },
                ],
                volumes: [
                    {
                        name: "sys-mount",
                        hostPath: {
                            path: "/sys",
                        },
                    },
                ],
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
} else "SKIP"
