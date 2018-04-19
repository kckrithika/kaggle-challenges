local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if sdnimages.phase == "1" || sdnimages.phase == "2" || sdnimages.phase == "3" || sdnimages.phase == "4" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                volumes: [
                    sdnconfigs.sdn_logs_volume,
                ],
                containers: [
                    {
                        name: "sdn-cleanup",
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-cleanup",
                            "--period=1440m",
                            "--logsMaxAge=48h",
                            "--filesDirToCleanup=" + sdnconfigs.logFilePath,
                            "--shouldNotDeleteAllFiles=false",
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
                            sdnconfigs.alsoLogToStdErrArg,
                        ],
                        volumeMounts: [
                            sdnconfigs.sdn_logs_volume_mount,
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
