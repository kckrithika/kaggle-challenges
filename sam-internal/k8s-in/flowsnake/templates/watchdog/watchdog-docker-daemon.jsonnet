local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local watchdog = import "watchdog.jsonnet";
if !watchdog.watchdog_enabled || !std.objectHas(flowsnake_images.feature_flags, "docker_daemon_monitor") then
"SKIP"
else
{
    apiVersion: "extensions/v1beta1",
    metadata: {
        name: "watchdog-docker-daemon",
        namespace: "flowsnake",
    },
    kind: "DaemonSet",
    spec: {
        template: {
            metadata: {
                labels: {
                    app: "watchdog-docker-daemon",
                    apptype: "monitoring"
                },
            },
            spec: {
                restartPolicy: "Always",
                hostNetwork: true,
                containers: [
                    {
                        image: flowsnake_images.docker_daemon_watchdog,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                        command: [
                            "/sam/watchdog",
                            "-role=CLI",
                            "-cliCheckerCommandTarget=DockerDaemon",
                            "-emailFrequency=" + watchdog.watchdog_email_frequency,
                            "-timeout=2s",
                            "-funnelEndpoint=" + flowsnakeconfig.funnel_vip_and_port,
                            "--config=/config/watchdog.json",
                            "--hostsConfigFile=/sfdchosts/hosts.json",
                            "-watchdogFrequency=1m",
                            "-alertThreshold=45m",
                            "-cliCheckerTimeout=5m",
                        ],
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
                        volumeMounts: [
                            {
                                name: "docker-socket",
                                mountPath: "/docker.sock",
                                readOnly: true
                            },
                            configs.config_volume_mount,
                        ],
                    },
                ],
                volumes: [
                    {
                        name: "docker-socket",
                        hostPath: {
                            path: "/var/run/docker.sock",
                        }
                    },
                    {
                      configMap: {
                        name: "watchdog",
                      },
                      name: "config",
                    },
                ],
            },
        },
    }
}
