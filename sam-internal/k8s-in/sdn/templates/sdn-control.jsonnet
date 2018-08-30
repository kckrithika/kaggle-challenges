local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "" then configs.deploymentBase("sdn") {
    metadata: {
        labels: {
            name: "sdn-control",
        } + configs.ownerLabel.sdn,
        name: "sdn-control",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxSurge: 1,
                maxUnavailable: 0,
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "sdn-control",
                } + configs.ownerLabel.sdn,
            },
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-control",
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-control-service",
                            "--archiveSvcEndpoint=" + sdnconfigs.archiveSvcEndpoint,
                            "--port=" + portconfigs.sdn.sdn_control_service,
                            "--charonAgentEndpoint=" + sdnconfigs.charonEndpoint,
                            "--livenessProbePort=" + portconfigs.sdn.sdn_control,
                            "--charonPushInterval=30s",
                            "--samUpdateInterval=30s",
                            "--sdncBootstrapTimer=30s",
                            "--ipamPullInterval=30s",
                            "--archiveSvcPullInterval=30s",
                            "--rootPath=/etc/pki_service",
                            "--userName=kubernetes",
                            "--pkiServerServiceName=k8s-server",
                            "--pkiClientServiceName=k8s-client",
                            "--enableNyxMtls",
                            configs.sfdchosts_arg,
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
                                port: portconfigs.sdn.sdn_control,
                            },
                            initialDelaySeconds: 30,
                            timeoutSeconds: 5,
                            periodSeconds: 30,
                        },
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            sdnconfigs.sdn_logs_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    sdnconfigs.sdn_logs_volume,
                ]),
                nodeSelector: {
                    pool: sdnconfigs.sdn_control_pool,
                    master: sdnconfigs.sdn_master,
                },
            },
        },
    },
} else "SKIP"
