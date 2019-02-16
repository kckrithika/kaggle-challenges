local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";
local samreleases = import "samreleases.json";

{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "watchdog-synthetic",
        } + configs.ownerLabel.sam
        + configs.pcnEnableLabel,
        name: "watchdog-synthetic",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        revisionHistoryLimit: 2,
        selector: {
            matchLabels: {
                name: "watchdog-synthetic",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "monitoring",
                    name: "watchdog-synthetic",
                } + configs.ownerLabel.sam,
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        command: [
                                     "/sam/watchdog",
                                     "-role=SYNTHETIC",
                                     if configs.kingdom == "prd" then "-watchdogFrequency=300s" else "-watchdogFrequency=180s",
                                     "-alertThreshold=1h",
                                     "-emailFrequency=12h",
                                     "-laddr=" + samwdconfig.laddr,
                                     # SAM AutoDeployer replaces "auto" keyword with the newest hypersam tag but only in containers[*].image, not in command line.  We will just use hypersam from next phase
                                     # TODO: When we move to the bundle controller and deployer bot we can move this back to simply be samimages.hypersam
                                     "-imageName=" + samimages.hypersam,
                                     "-watchDogKind=" + $.kind,
                                     "-enableStatefulChecks=false",
                                 ]
                                 + samwdconfig.shared_args
                                 + (if samfeatureflags.syntheticwdPagerDutyEnabled then samwdconfig.low_urgency_pagerduty_args else []),
                        ports: [
                            {
                                name: "synthetic",
                                containerPort: samwdconfig.syntheticPort,
                            },
                        ],
                        image: samimages.hypersam,
                        name: "watchdog-synthetic",
                        volumeMounts+: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            {
                                mountPath: "/test",
                                name: "test",
                            },
                            {
                                mountPath: "/_output",
                                name: "output",
                            },
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                        ]),
                    }
                    + configs.containerInPCN,
                ],
                hostNetwork: true,
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },

                volumes+: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    {
                        hostPath: {
                            path: "/manifests",
                        },
                        name: "sfdc-volume",
                    },
                    {
                        emptyDir: {},
                        name: "test",
                    },
                    {
                        emptyDir: {},
                        name: "output",
                    },
                    configs.config_volume("watchdog"),
                ]),
            } + configs.serviceAccount,
        },
    },
}
