local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flag_fs_metric_labels = std.objectHas(flowsnakeimage.feature_flags, "fs_metric_labels");
{
    local label_node = self.spec.template.metadata.labels,
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "default-http-backend",
        },
        name: "default-http-backend",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                app: label_node.app,
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "default-http-backend",
                    app: "default-http-backend",
                } + if flag_fs_metric_labels then {
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "DefaultHttpBackend",
                } else {},
            },
            spec: {
                terminationGracePeriodSeconds: 60,
                containers: [
                    {
                        name: "default-http-backend",
                        image: flowsnakeimage.ingress_default_backend,
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 8080,
                                scheme: "HTTP",
                            },
                            initialDelaySeconds: 30,
                            timeoutSeconds: 5,
                        },
                        ports: [
                            {
                                containerPort: 8080,
                            },
                        ],
                        resources: {
                            limits: {
                                cpu: "10m",
                                memory: "20Mi",
                            },
                            requests: {
                                cpu: "10m",
                                memory: "20Mi",
                            },
                        },
                    },
                ],
            },
        },
    },
}
