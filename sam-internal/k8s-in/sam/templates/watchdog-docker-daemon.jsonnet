local flowsnake_images = (import "../flowsnake/flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local configs = import "config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local samwdconfig = import "samwdconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

configs.daemonSetBase("sam") {
    spec+: {
        template: {
            metadata: {
                labels: {
                    app: "watchdog-docker-daemon",
                    apptype: "monitoring",
                    daemonset: "true",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                restartPolicy: "Always",
                hostNetwork: true,  # NOTE: this pod *does* count against the IP limit, because it starts a Docker container on the default network
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        image: flowsnake_images.docker_daemon_watchdog,
                        command: [
                            "/sam/watchdog",
                            "-role=CLI",
                            "-cliCheckerCommandTarget=DockerDaemon",
                            "-alertThreshold=30m",
                            "-watchDogKind=" + $.kind,
                            "--recipient=",
                            "-cliCheckerTimeout=5m",
                        ] + samwdconfig.shared_args,
                        name: "watchdog-docker-daemon",
                        resources: {
                            requests: {
                                cpu: "0.1",
                                memory: "100Mi",
                            },
                            limits: {
                                cpu: "0.1",
                                memory: "100Mi",
                            },
                        },
                        volumeMounts+: [
                            {
                                name: "docker-socket",
                                mountPath: "/docker.sock",
                                readOnly: true,
                            },
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ],
                    },
                ],
                volumes+: [
                    {
                        name: "docker-socket",
                        hostPath: {
                            path: "/var/run/docker.sock",
                        },
                    },
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("watchdog"),
                ],
            },
        },
    },
    metadata+: {
        labels: {
            name: "watchdog-docker-daemon",
        } + configs.ownerLabel.sam,
        name: "watchdog-docker-daemon",
        namespace: "sam-system",
    },
}
