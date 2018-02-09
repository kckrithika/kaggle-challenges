local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
{

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sam-deployment-reporter",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                           "/sam/sam-deployment-reporter",
                           "--v=5",
                           "--k8sapiserver=",
                           "--smtpServer=" + configs.smtpServer,
                           "--sender=sam@salesforce.com",
                           "--defaultRecipient=",
                           "--namespacesToSkip=sam-watchdog",
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
                    } + (if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
                        livenessProbe: {
                           httpGet: {
                             path: "/healthz",
                             port: 9029,
                           },
                           initialDelaySeconds: 30,
                           periodSeconds: 5,
                        },
                    } else {}),
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
                    name: "sam-deployment-reporter",
                    apptype: "control",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "sam-deployment-reporter",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sam-deployment-reporter",
        },
        name: "sam-deployment-reporter",
        namespace: "sam-system",
    },
}
