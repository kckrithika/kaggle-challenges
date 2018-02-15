local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "stateful-revision-cleaner",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                           "/sam/stateful-revision-cleaner",
                           "--v=5",
                           "--k8sapiserver=",
                           "--namespacesToSkip=sam-watchdog,legostore,sam-system,sf-store",
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
                    name: "stateful-revision-cleaner",
                    apptype: "control",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "stateful-revision-cleaner",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "stateful-revision-cleaner",
        },
        name: "stateful-revision-cleaner",
        namespace: "sam-system",
    },
} else "SKIP"
