local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
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
                        command:[
                           "/sam/sam-deployment-reporter",
                           "--v=5",
                           "--k8sapiserver="+configs.k8sapiserver,
                           "--smtpServer="+configs.smtpServer,
                           "--sender=sam@salesforce.com",
                           "--defaultRecipient=",
                           "--namespacesToSkip=sam-watchdog",
                           ],
                       volumeMounts: configs.cert_volume_mounts + [
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                       ],
                       env: [
                          configs.kube_config_env,
                       ]
                    }
                ],
                volumes: configs.cert_volumes + [
                    configs.cert_volume,
                    configs.kube_config_volume,
                ],
                nodeSelector: {
                    pool: configs.estate
                } +
                if configs.estate == "prd-samtest" then {
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    master: "true"
                } else {},
            },
            metadata: {
                labels: {
                    name: "sam-deployment-reporter",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "sam-deployment-reporter"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sam-deployment-reporter"
        },
        name: "sam-deployment-reporter",
        namespace: "sam-system"
    }
}
