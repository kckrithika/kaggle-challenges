local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "k8s-resource-reporter",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                           "/sam/k8s-resource-reporter",
                           "--v=5",
                           "--k8sapiserver=",
                           "--smtpServer=" + configs.smtpServer,
                           "--sender=sam@salesforce.com",
                           "--defaultRecipient=mayank.kumar@salesforce.com",
                           "--namespacesToSkip=sam-watchdog,legostore,sam-system",
                           configs.sfdchosts_arg,
                           ]),
                       volumeMounts: configs.filter_empty([
                          configs.sfdchosts_volume_mount,
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                       ]),
                       env: [
                          configs.kube_config_env,
                       ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
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
                    name: "k8s-resource-reporter",
                    apptype: "control",
                },
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
        },
        name: "k8s-resource-reporter",
        namespace: "sam-system",
    },
} else "SKIP"
