local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.sloop then configs.daemonSetBase("sam") {
    spec+: {
        template: {
            spec: {
                hostNetwork: true,
                serviceAccountName: "sloop",
                containers: [
                    {
                        name: "sloopds",
                        resources: {
                            requests: {
                                cpu: "1",
                                memory: "12Gi",
                            },
                            limits: {
                                cpu: "1",
                                memory: "12Gi",
                            },
                        },
                        args: [
                            "--config=/sloopconfig/sloop.yaml",
                            "--port=" + portconfigs.sloop.sloop,
                        ],
                        command: [
                            "/sloop",
                        ],
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/sloop:thargrove-20200106_083558-0acb2a2",
                        volumeMounts: [
                            {
                                name: "sloop-data",
                                mountPath: "/data/",
                            },
                            {
                                name: "sloopconfig",
                                mountPath: "/sloopconfig/",
                            },
                        ],
                        ports: [
                            {
                                containerPort: portconfigs.sloop.sloop,
                                protocol: "TCP",
                            },
                        ],
                    },
                    {
                        name: "prometheus",
                        args: [
                            "--config.file",
                            "/prometheusconfig/prometheus.json",
                        ],
                        image: samimages.prometheus,
                        volumeMounts: [
                            {
                                name: "prom-data",
                                mountPath: "/data",
                            },
                            {
                                name: "sloopconfig",
                                mountPath: "/prometheusconfig",
                            },
                        ],
                        ports: [
                            {
                                containerPort: 9090,
                                protocol: "TCP",
                            },
                        ],
                    },
                ],
                volumes+: [
                    {
                        hostPath: {
                            path: "/data/sloop-data",
                        },
                        name: "sloop-data",
                    },
                    {
                        hostPath: {
                            path: "/data/sloop-prom-data",
                        },
                        name: "prom-data",
                    },
                    {
                        configMap: {
                            name: "sloop",
                        },
                        name: "sloopconfig",
                    },
                ],
                nodeSelector: {
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    app: "sloopds",
                    apptype: "monitoring",
                    daemonset: "true",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "25%",
            },
        },
    },
    metadata+: {
        labels: {
            name: "sloopds",
        } + configs.ownerLabel.sam,
        name: "sloopds",
    },
} else "SKIP"
