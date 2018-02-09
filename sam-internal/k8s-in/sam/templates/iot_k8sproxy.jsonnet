local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then {
# This is just to unblock IOT Team since their pipeline uses port 5000. Should be removed after they are able to access proxy at port 40000
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "iotk8sproxy",
                        image: samimages.k8sproxy,
                        args: [
                        ] + (if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then [
                          "-f",
                          "/k8sproxyconfig/haproxy-maddog.cfg",
                        ] else [
                          "-f",
                          "/etc/haproxy/haproxy.cfg",
                        ]),
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            {
                                name: "sfdc-volume",
                                mountPath: "/etc/certs",
                            },
                            {
                                name: "k8sproxyconfig",
                                mountPath: "/k8sproxyconfig",
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
                   "kubernetes.io/hostname": "shared0-samcompute1-1-prd.eng.sfdc.net",
                },

            },
            metadata: {
                labels: {
                    name: "iotk8sproxy",
                    apptype: "proxy",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "iotk8sproxy",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "iotk8sproxy",
        },
        name: "iotk8sproxy",
        namespace: "sam-system",
    },
} else "SKIP"
