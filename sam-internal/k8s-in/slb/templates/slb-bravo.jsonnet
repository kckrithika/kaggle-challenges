local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-bravo",
        },
        name: "slb-bravo",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-bravo",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    {
                        name: "dev-volume",
                        hostPath: {
                            path: "/dev",
                         },
                    },
                    slbconfigs.host_volume,
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-bravo",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-bravo-svc",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--ports=9090,9091,9092",
                        ]
                        + (
                           if configs.estate == "prd-sdc" then [
                            "--tlsPorts=" + portconfigs.slb.canaryServiceTlsPort,
                            "--publicKey=/var/slb/canarycerts/sdc.crt",
                            "--privateKey=/var/slb/canarycerts/server.key",
                           ] else []
                          ),

                        volumeMounts: configs.filter_empty([
                            {
                                name: "dev-volume",
                                mountPath: "/dev",
                            },
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
        },
    },
} else "SKIP"
