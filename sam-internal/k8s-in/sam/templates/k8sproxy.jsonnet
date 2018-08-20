local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.k8sproxy then {
    kind: "Deployment",
    spec: {
        replicas: 3,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "k8sproxy",
                        image: samimages.k8sproxy,
                        args: [
                                 "-f",
                                 "/k8sproxyconfig/haproxy.cfg",
                             ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            {
                                name: "k8sproxyconfig",
                                mountPath: "/k8sproxyconfig",
                            },
                            {
                                name: "sfdc-volume",
                                mountPath: "/etc/certs",
                            },
                        ]),
                        ports: [
                            {
                                containerPort: 5000,
                                name: "k8sproxy",
                            },
                        ],
                        livenessProbe: {
                            initialDelaySeconds: 15,
                            httpGet: {
                                path: "/",
                                port: 5000,
                            },
                            timeoutSeconds: 10,
                        },
                    },
                ],
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    {
                        hostPath: {
                            path: "/data/certs",
                        },
                        name: "sfdc-volume",
                    },
                    {
                        configMap: {
                            name: "k8sproxy",
                        },
                        name: "k8sproxyconfig",
                    },
                ]),
                nodeSelector: {
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    name: "k8sproxy",
                    apptype: "proxy",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "k8sproxy",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "k8sproxy",
        } + configs.ownerLabel.sam,
        name: "k8sproxy",
        namespace: "sam-system",
    },
} else "SKIP"
