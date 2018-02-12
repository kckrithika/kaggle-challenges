local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

#Keep the below if statement in sync with the one in snapshoter-configmap.jsonnet

{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshoter",
        },
        name: "snapshoter",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshoter",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshoter",
                },
                namespace: "sam-system",
            },
            spec: {
                containers: [{
                    command: [
"/sam/snapshoter",
                        "--config=/config/snapshoter.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "--v=4",
                        "--alsologtostderr",
],
                    volumeMounts: configs.filter_empty([
                           configs.sfdchosts_volume_mount,
                           configs.maddog_cert_volume_mount,
                           configs.cert_volume_mount,
                           configs.kube_config_volume_mount,
                           configs.config_volume_mount,
                    ]),
                    env: [
                     configs.kube_config_env,
                    ],
                    livenessProbe: {
                       httpGet: {
                             path: "/",
                             port: 9095,
                       },
                       initialDelaySeconds: 20,
                       periodSeconds: 20,
                       timeoutSeconds: 20,
                    },
                    image: samimages.hypersam,
                    name: "snapshoter",
                }],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("snapshoter"),
                 ]),
                hostNetwork: true,
                nodeSelector: {
                } +
                if configs.kingdom == "prd" then {
                    master: "true",
                } else {
                     pool: configs.estate,
                },
            },
        },
    },
}
