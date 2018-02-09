local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
if configs.kingdom == "prd" && configs.estate != "prd-sam_storage" && configs.estate != "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 3,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                       name: "sam-deployment-portal",
                       image: samimages.hypersam,
                       command: configs.filter_empty([
                          "/sam/sam-deployment-portal",
                          configs.sfdchosts_arg,
                          "--alsologtostderr",
                       ]),
                       ports: [
                       {
                           containerPort: 64121,
                       },
                       ],
                       volumeMounts: configs.filter_empty([
                          configs.sfdchosts_volume_mount,
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          {
                             mountPath: "/var/token",
                             name: "token",
                             readOnly: true,
                          },
                       ]),
                       env: [
                          configs.kube_config_env,
                       ],
                       livenessProbe: {
                           initialDelaySeconds: 15,
                           httpGet: {
                               path: "/",
                               port: 64121,
                           },
                           timeoutSeconds: 10,
                       },
                       workingDir: "/sam",
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    {
                        secret: {
                              secretName: "git-token",
                        },
                        name: "token",
                    },
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
                    name: "sam-deployment-portal",
                    apptype: "control",
                },
               namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "sam-deployment-portal",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sam-deployment-portal",
        },
        name: "sam-deployment-portal",
    },
} else "SKIP"
