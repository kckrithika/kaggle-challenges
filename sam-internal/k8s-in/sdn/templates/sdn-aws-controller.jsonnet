local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "cdu-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "sdn-aws-controller",
        },
        name: "sdn-aws-controller",
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
                    name: "sdn-aws-controller",
                },
            },
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-aws-controller",
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-aws-controller",
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--livenessProbePort=" + portconfigs.sdn.sdn_aws_controller,
                            "--ipamPullInterval=30s",
                            "--archiveSvcPullInterval=30s",
                            "--rootPath=/etc/pki_service",
                            "--userName=kubernetes",
                            "--pkiServerServiceName=k8s-server",
                            "--pkiClientServiceName=k8s-client",
                            "--awsRegion=" + sdnconfigs.awsRegion,
                            "--awsAZ=" + sdnconfigs.awsAZ,
                            "--ddi=" + sdnconfigs.ddiService,
                            "--keyfile=" + configs.keyFile,
                            "--certfile=" + configs.certFile,
                            "--cafile=" + configs.caFile,
                            configs.sfdchosts_arg,
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
                        ],
                        env: [
                            configs.kube_config_env,
                        ],
                        livenessProbe: {
                            httpGet: {
                                path: "/liveness-probe",
                                port: portconfigs.sdn.sdn_aws_controller,
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
