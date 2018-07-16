local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "illumio-dsr-host",
        } + slbconfigs.ownerLabel,
        name: "illumio-dsr-host",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "illumio-dsr-host",
                } + slbconfigs.ownerLabel,
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "illumio-dsr-host",
                        image: slbimages.hypersdn,
                        command: [
                                     "/sdn/slb-canary-service",
                                     "--serviceName=illumio-dsr-host",
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--ports=8443",
                                 ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    },
                ],
                hostNetwork: true,
                nodeSelector: {
                    pool: configs.estate,
                },
            },
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
