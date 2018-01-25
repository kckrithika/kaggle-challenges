local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samtest" then {
   kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "prometheus",
                        image: samimages.prometheus,
                        args: [
                          "-f",
                          "/prometheusconfig/prometheus.cfg",
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "certs-volume",
                                mountPath: "/etc/pki_service",
                            },
                            {
                                name: "prom-data",
                                mountPath: "/prometheus",
                            },
                            {
                                name: "prometheusconfig",
                                mountPath: "/prometheusconfig",
                            },
                        ]),
                        ports: [
                        {
                            containerPort: 9090,
                            name: "prometheus",
                        },
                        ],
                      livenessProbe: {
                           initialDelaySeconds: 15,
                           httpGet: {
                               path: "/",
                               port: 9090,
                           },
                           timeoutSeconds: 10,
                        },
                    },
                ],
                volumes: configs.filter_empty([
                    {
                        hostPath: {
                            path: "/etc/pki_service",
                        },
                        name: "certs-volume",
                    },
                    {
                        hostPath: {
                            path: "/root/prom-data",
                        },
                        name: "prom-data",
                    },
                    {
                        configMap: {
                            name: "prometheus",
                        },
                        name: "prometheusconfig",
                    },
                ]),
            },
            metadata: {
                labels: {
                    name: "prometheus",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "prometheus",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "prometheus",
        },
        name: "prometheus",
        namespace: "sam-system",
    },
} else "SKIP"
