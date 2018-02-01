local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                volumes: [
                    sdnconfigs.logs_volume,
                ],
                containers: [
                    {
                        name: "sdn-cleanup",
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-cleanup",
                            "--period=300s",
                            "--logsMaxAge=48h",
                            "--filesDirToCleanup=" + sdnconfigs.logFilePath,
                            "--shouldNotDeleteAllFiles=false",
                        ],
                        volumeMounts: [
                            sdnconfigs.logs_volume_mount,
                        ],
                        env: [
                            configs.kube_config_env,
                        ],
                        securityContext: {
                            privileged: true,
                        },
                    },
                ],
            },
            metadata: {
                labels: {
                    name: "sdn-cleanup",
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
            name: "sdn-cleanup",
        },
        name: "sdn-cleanup",
        namespace: "sam-system",
    },
} else "SKIP"
