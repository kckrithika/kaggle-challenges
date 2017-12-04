local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "alerthandler",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    app: "alerthandler",
                },
            },
            spec: {
                volumes:
                    configs.filter_empty([
                        configs.maddog_cert_volume,
                        configs.cert_volume,
                        configs.kube_config_volume,
                    ]),
                containers: [
                    {
                        name: "alerthandler",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/foundation/alerthandler:latest",
                        ports: [
                            {
                                name: "alert-hook",
                                containerPort: 5001,
                                protocol: "TCP",
                            },
                            {
                                name: "alert-publisher",
                                containerPort: 5002,
                                protocol: "TCP",
                            },
                        ],
                        env: [
                            configs.kube_config_env,
                        ],
                        volumeMounts:
                            configs.filter_empty([
                                configs.maddog_cert_volume_mount,
                                configs.cert_volume_mount,
                                configs.kube_config_volume_mount,
                            ]),
                    },
                ],
            },
        },
    },
} else "SKIP"
