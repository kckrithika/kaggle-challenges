local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
if !utils.is_public_cloud(configs.kingdom) then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sam-secret-agent",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                           "/sam/sam-secret-agent",
                           "--funnelEndpoint=" + configs.funnelVIP,
                           "--logtostderr=true",
                           "--disableSecurityCheck=true",
                           "--tnrpEndpoint=" + configs.tnrpArchiveEndpoint,
                           "--observeMode=" + false,
                           "--delay=300s",
                           "--keyfile=" + configs.keyFile,
                           "--certfile=" + configs.certFile,
                           "--cafile=" + configs.caFile,
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
                         livenessProbe: {
                           httpGet: {
                             path: "/",
                             port: 9098,
                           },
                           initialDelaySeconds: 2,
                           periodSeconds: 10,
                           timeoutSeconds: 10,
                        },
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
                    name: "sam-secret-agent",
                    apptype: "control",
                },
               namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sam-secret-agent",
        },
        name: "sam-secret-agent",
    },
} else "SKIP"
