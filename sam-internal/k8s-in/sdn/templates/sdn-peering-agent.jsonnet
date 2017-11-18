local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-bird",
                        image: sdnimages.bird,
                        livenessProbe: {
                            exec: {
                               command: [
                                    "/bird/sdn-bird-watcher",
                               ],
                            },
                            initialDelaySeconds: 5,
                            periodSeconds: 10,
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
                        ]),
                        env: [
                            {
                                name: "BIRD_CONF",
                                value: "/usr/local/etc/bird.conf",
                            },
                            {
                                name: "BIRD_SOCKET",
                                value: "/usr/local/var/run/bird.ctl",
                            },
                        ],
                    },
                    {
                        name: "sdn-peering-agent",
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-peering-agent",
                            "--birdsock=/usr/local/var/run/bird.ctl",
                            "--birdconf=/usr/local/etc/bird.conf",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--keyfile=" + configs.keyFile,
                            "--certfile=" + configs.certFile,
                            "--bgpPasswordFile=/data/secrets/sambgppassword",
                            "--livenessProbePort=" + portconfigs.sdn.sdn_peering_agent,

                        ]
                        + (if configs.estate == "prd-sdc" then
                        [
                            "--sdncServiceName=sdn-control-svc",
                            "--sdncNamespace=sam-system",
                            "--rootPath=/etc/pki_service",
                            "--userName=kubernetes",
                            "--pkiClientServiceName=k8s-client",
                        ] else if configs.kingdom == "prd" || configs.estate == "frf-sam" then ["--controlEstate=" + configs.estate] else ["--controlEndpoint=" + configs.estate]),
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
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    {
                        name: "conf",
                        emptyDir: {},
                    },
                    {
                        name: "socket",
                        emptyDir: {},
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
