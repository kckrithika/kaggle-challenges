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
                        name: "samcontrol-deployer",
                        image: samimages.hypersam,
                        command: [
                           "/sam/samcontrol-deployer",
                           "--funnelEndpoint="+configs.funnelVIP,
                           "--logtostderr=true",
                           "--disableSecurityCheck=true",
                           "--tnrpEndpoint="+configs.tnrpArchiveEndpoint,
                           "--k8sapiserver="+configs.k8sapiserver,
                           "--observeMode="+configs.samcontrol_deployer_ObserveMode,
                           "--delay=30s",
                           "--emailNotify="+configs.samcontrol_deployer_EmailNotify,
                           "--smtpServer="+configs.smtpServer,
                           "--sender=sam@salesforce.com",
                           "--recipient=sam@salesforce.com",
                           "--caFile="+configs.caFile,
                           "--keyFile="+configs.keyFile,
                           "--certFile="+configs.certFile,
                         ],
                         "volumeMounts": [
                           configs.cert_volume_mount,
                           configs.kube_config_volume_mount,
                         ],
                         env: [
                           configs.kube_config_env,
                         ],
                         livenessProbe: {
                           "httpGet": {
                             "path": "/",
                             "port": 9099
                           },
                           "initialDelaySeconds": 2,
                           "periodSeconds": 10,
                           "timeoutSeconds": 10
                        }
                    }
                ],
                volumes: [
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
                } else {}
            },
            metadata: {
                labels: {
                    name: "samcontrol-deployer",
                    apptype: "control"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samcontrol-deployer"
        },
        name: "samcontrol-deployer"
    }
}
