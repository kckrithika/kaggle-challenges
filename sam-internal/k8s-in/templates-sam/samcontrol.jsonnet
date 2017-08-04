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
                        name: "sam-controller",
                        image: samimages.hypersam,
                        command:[
                           "/sam/sam-controller",
                           "--dockerregistry="+configs.registry,
                           "--funnelEndpoint="+configs.funnelVIP,
                           "--v=3",
                           "--logtostderr=true",
                           "--k8sapiserver="+configs.k8sapiserver,
                           "--tlsEnabled=true",
                           "--caFile="+configs.caFile,
                           "--keyFile="+configs.keyFile,
                           "--certFile="+configs.certFile,
                           "--checkImageExistsFlag=true",
                           "--httpsDisableCertsCheck=true",
                           "--volPermissionInitContainerImage="+samimages.permissionInitContainer,
                           ]
                           + (if configs.kingdom == "prd" then [ "--deletionEnabled=true", "--deletionPercentageThreshold=10"] else [])
                           + (if configs.kingdom == "prd" then [ "--statefulAppEnabled=true" ] else [])
                           + (if configs.kingdom != "prd" then [ "--debug=true" ] else []),
                       volumeMounts: [
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          configs.config_volume_mount,
                       ],
                       env: [
                          configs.kube_config_env,
                       ]
                    }
                ],
                volumes: [
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("samcontrol"),
                ],
                nodeSelector: {
                    pool: configs.estate,
                } +
                if configs.estate == "prd-samtest" then {
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    master: "true"
                } else {}
            },
            metadata: {
                labels: {
                    name: "samcontrol",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "samcontrol"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samcontrol"
        },
        name: "samcontrol"
    }
}
