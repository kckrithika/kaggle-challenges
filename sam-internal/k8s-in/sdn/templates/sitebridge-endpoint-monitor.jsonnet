local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local sdnconfig = import "sdnconfig.jsonnet";
if configs.estate == "prd-sdc" then configs.daemonSetBase("sdn") {
    spec+: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sitebridge-endpoint-monitor",
                        image: sdnimages.sitebridge,
                        command: [
                            "/sitebridge/sitebridge-endpoint-monitor",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--livenessProbePort=" + portconfigs.sdn.sitebridge_endpoint_monitor,
                            "--enableCurlAgent=true",
                            "--enableResolveAgent=false",
                            "--jobNames=gitTest",
                            "--resolveDomains=scm-ghe1-2.sfdctest.dev.sfdcsb.net",
                            "--jobEndpoints=https://scm-ghe1-2.sfdctest.dev.sfdcsb.net",
                            "--jobCycleTimes=20",
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
                            sdnconfigs.alsoLogToStdErrArg,
                        ],
                        env: [
                            configs.kube_config_env,
                        ],
                        livenessProbe: {
                            httpGet: {
                               path: "/liveness-probe",
                               port: portconfigs.sdn.sitebridge_endpoint_monitor,
                            },
                            initialDelaySeconds: 5,
                            timeoutSeconds: 5,
                            periodSeconds: 20,
                        },
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            {
                                name: "certs",
                                mountPath: "/data/certs",
                            },
                            sdnconfigs.sdn_logs_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    {
                        name: "certs",
                        hostPath: {
                            path: "/data/certs",
                        },
                    },
                    sdnconfigs.sdn_logs_volume,
                ]),
            },
            metadata: {
                labels: {
                    name: "sitebridge-endpoint-monitor",
                    apptype: "control",
                    daemonset: "true",
                } + (if configs.kingdom != "prd" &&
                        configs.kingdom != "xrd" then
                        configs.ownerLabel.sdn else {}),
                namespace: "sam-system",
            },
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
            maxUnavailable: "50%",
            },
        },
    },
    metadata: {
        labels: {
            name: "sitebridge-endpoint-monitor",
        },
        name: "sitebridge-endpoint-monitor",
        namespace: "sam-system",
    },
} else "SKIP"
