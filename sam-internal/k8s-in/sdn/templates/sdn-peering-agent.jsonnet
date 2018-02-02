local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";
local sdnconfig = import "sdnconfig.jsonnet";
if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-peering-agent",
                        image: sdnimages.hypersdn,
                        command: std.prune([
                            "/sdn/sdn-peering-agent",
                            "--birdsock=/usr/local/var/run/bird.ctl",
                            "--birdconf=/usr/local/etc/bird.conf",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--keyfile=" + configs.keyFile,
                            "--certfile=" + configs.certFile,
                            "--bgpPasswordFile=" + sdnconfig.bgpPasswordFilePath,
                            "--livenessProbePort=" + portconfigs.sdn.sdn_peering_agent,
                            "--sdncServiceName=sdn-control-svc",
                            "--sdncNamespace=sam-system",
                            "--rootPath=/etc/pki_service",
                            "--userName=kubernetes",
                            "--pkiClientServiceName=k8s-client",
                            configs.sfdchosts_arg,
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                        livenessProbe: {
                            httpGet: {
                               path: "/liveness-probe",
                               port: portconfigs.sdn.sdn_peering_agent,
                            },
                            initialDelaySeconds: 5,
                            timeoutSeconds: 5,
                            periodSeconds: 20,
                        },
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            {
                                name: "conf",
                                mountPath: "/usr/local/etc",
                            },
                            {
                                name: "socket",
                                mountPath: "/usr/local/var/run",
                            },
                            {
                                name: "certs",
                                mountPath: "/data/certs",
                            },
                            {
                                name: "secrets",
                                mountPath: "/data/secrets",
                                readOnly: true,
                            },
                            configs.kube_config_volume_mount,
                            sdnconfigs.conditional_sdn_logs_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    {
                        name: "conf",
                        hostPath: {
                            path: "/etc/kubernetes/sdn",
                        },
                    },
                    {
                        name: "socket",
                        hostPath: {
                            path: "/etc/kubernetes/sdn",
                        },
                    },
                    {
                        name: "certs",
                        hostPath: {
                            path: "/data/certs",
                        },
                    },
                    {
                        name: "secrets",
                        secret: {
                            defaultMode: 256,
                            secretName: "sdn",
                        },
                    },
                    configs.kube_config_volume,
                    sdnconfigs.conditional_sdn_logs_volume,
                ]),
            },
            metadata: {
                labels: {
                    name: "sdn-peering-agent",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-peering-agent",
        },
        name: "sdn-peering-agent",
        namespace: "sam-system",
    },
} else "SKIP"
