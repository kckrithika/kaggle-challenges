local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "k8s-resource-reporter",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/k8s-resource-reporter",
                            "--v=5",
                            "--k8sapiserver=",
                            "--smtpServer=" + configs.smtpServer,
                            "--sender=sam@salesforce.com",
                            "--defaultRecipient=mayank.kumar@salesforce.com",
                            "--namespacesToSkip=sam-watchdog,legostore,sam-system,sf-store",
                            configs.sfdchosts_arg,
                        ]),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                ],
                nodeSelector: {
                              } +
                              if !utils.is_production(configs.kingdom) then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "k8s-resource-reporter",
                    apptype: "control",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "k8s-resource-reporter",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "k8s-resource-reporter",
        } + configs.ownerLabel.sam,
        name: "k8s-resource-reporter",
        namespace: "sam-system",
    },
}
