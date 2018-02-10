local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-canary-proxy-http",
        },
        name: "slb-canary-proxy-http",
        namespace: "sam-system",
    },
    spec: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary-proxy-http",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-canary-proxy-http",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-canary-service",
                            "--serviceName=slb-canary-proxy-http",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--ports=" + portconfigs.slb.canaryServiceProxyHttpPort,
                        ]
                        + (
                            if configs.estate == "prd-sdc" then [
                                "--healthPort=" + portconfigs.slb.canaryServiceHealthPort,
                                "--markerPath=" + slbconfigs.logsDir,
                            ] else []
                        ),
                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    }
                    + (
                        if configs.estate == "prd-sdc" then {
                            livenessProbe: {
                                httpGet: {
                                    path: "/",
                                    port: portconfigs.slb.canaryServiceProxyHttpPort,
                                },
                                initialDelaySeconds: 15,
                                periodSeconds: 10,
                            },
                        }
                        else {}
                       ),
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
        },
    },
} else "SKIP"
