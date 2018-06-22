local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

# This is the maddog watchdog for services used by SAM apps using maddog

if samfeatureflags.maddogforsamapps then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-maddog",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=MADDOG",
                                     "-watchdogFrequency=10s",
                                     "-alertThreshold=300s",
                                     "-madkub-endpoint=https://$(MADKUBSERVER_SERVICE_HOST):32007/healthz",
                                     "-maddog-endpoint=" + configs.maddogEndpoint + "/sfdc/v1/ping",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args
                                 + ["-emailFrequency=24h"],
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.config_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("watchdog"),
                ]),
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "watchdog-maddog",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-maddog",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-maddog",
        },
        name: "watchdog-maddog",
    },
} else "SKIP"
