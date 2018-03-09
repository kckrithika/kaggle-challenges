local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" || configs.kingdom == "iad" || configs.kingdom == "ord" then
    {
        kind: "Deployment",
        spec: {
            replicas: 1,
            template: {
                spec: {
                    hostNetwork: true,
                    containers: [
                        {
                            name: "temp-secret-samcontrol-deployer",
                            image: samimages.hypersam,
                            command: configs.filter_empty([
                                "/sam/samcontrol-deployer",
                                "--config=/config/tempsecretsamcontroldeployer.json",
                                configs.sfdchosts_arg,
                            ]),
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
                                } + (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
                                         port: 9123,
                                     } else {
                                         port: 9099,
                                     }),


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
                        configs.config_volume("temp-secret-samcontrol-deployer"),
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
                        name: "temp-secret-samcontrol-deployer",
                        apptype: "control",
                    },
                },
            },
        },
        apiVersion: "extensions/v1beta1",
        metadata: {
            labels: {
                name: "temp-secret-samcontrol-deployer",
            },
            name: "temp-secret-samcontrol-deployer",
            namespace: "sam-system",
        },
    } else "SKIP"
