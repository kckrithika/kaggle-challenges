local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.kingdom == "prd" then {
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
                            "--livenessProbePort=" + portconfigs.sdn.sdn_hairpin_setter,
                        ]
                        livenessProbe: {
                            httpGet: {
                               path: "/liveness-probe",
                               port: portconfigs.sdn.sdn_hairpin_setter,
                            },
                            initialDelaySeconds: 5,
                            timeoutSeconds: 5,
                            periodSeconds: 20,
                        },
                        volumeMounts: configs.filter_empty([
                            {
                                name: "sys-mount",
                                mountPath: "/sys",
                            },
                        ]),
                        securityContext: {
                            privileged: true
                        },
                    },
                ],
                volumes: [
                    {
                        name: "sys-mount",
                        hostPath: {
                            path: "/sys",
                        }
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