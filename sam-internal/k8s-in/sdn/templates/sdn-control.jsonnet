local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "sdn-control",
        },
        name: "sdn-control",
        namespace: "sam-system",
    },
    spec: {
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
                },
            },
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-control",
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-control-service",
                            "--archiveSvcEndpoint=http://10.253.152.173:14431/tnrp/content_repo/0/archive",
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
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
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
