local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local hosts = import "configs/hosts.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                containers: [
                    {
                        name: "prometheus-rm",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/lizhang/prometheus:11212018",
                        args: [
                            "--config.file",
                            "/prometheusconfig/prometheus-rm.json",
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "certs-volume",
                                mountPath: "/etc/pki_service",
                            },
                            {
                                name: "prom-rm-data",
                                mountPath: "/prometheus",
                            },
                            {
                                name: "prometheusconfig-rm",
                                mountPath: "/prometheusconfig",
                            },
                        ]),
                        ports: [
                            {
                                containerPort: 9090,
                                name: "prometheus-rm",
                            },
                        ],
                        livenessProbe: {
                            initialDelaySeconds: 300,
                            httpGet: {
                                path: "/",
                                port: 9090,
                            },
                            timeoutSeconds: 30,
                        },
                    } + configs.ipAddressResourceRequest,
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
                            path: "/data/prom-rm-data",
                        },
                        name: "prom-rm-data",
                    },
                    {
                        configMap: {
                            name: "prometheus-rm",
                        },
                        name: "prometheusconfig-rm",
                    },
                ]),
                nodeSelector: {
                    # TODO: Find a better way to do this.
                    "kubernetes.io/hostname": [h.hostname for h in hosts.hosts if h.controlestate == std.extVar("estate") && h.kingdom == std.extVar("kingdom") && std.endsWith(std.split(h.hostname, "-")[1], "kubeapi3")][0],
                },
            },

            metadata: {
                labels: {
                    name: "prometheus-rm",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "prometheus-rm",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "prometheus-rm",
        } + configs.ownerLabel.sam,
        name: "prometheus-rm",
        namespace: "sam-system",
    },
} else "SKIP"
