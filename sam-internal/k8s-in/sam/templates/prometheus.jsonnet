local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
local hosts = import "configs/hosts.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
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
                          "--config.file",
                          "/prometheusconfig/prometheus.json",
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
                            path: "/data/prom-data",
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
                nodeSelector: {
                    "kubernetes.io/hostname": [h.hostname for h in hosts.hosts if h.controlestate == std.extVar("estate") && h.kingdom == std.extVar("kingdom") && std.endsWith(std.split(h.hostname, "-")[1], "kubeapi2")][0],
                },
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
