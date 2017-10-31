local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "nginx-ingress-controller",
        namespace: "flowsnake",
        labels: {
            name: "nginx-ingress-lb",
            "k8s-app": "nginx-ingress-lb"
        }
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                "k8s-app": "nginx-ingress-lb"
            }
        },
        template: {
            metadata: {
                labels: {
                    name: "nginx-ingress-lb",
                    "k8s-app": "nginx-ingress-lb"
                }
            },
            spec: {
                terminationGracePeriodSeconds: 60,
                containers: [
                    {
                        name: "nginx-ingress-lb",
                        image: flowsnakeconfig.registry + "/flowsnake-ingress-controller-nginx:" + flowsnakeimage.fleet_image_tag,
                        imagePullPolicy: "Always",
                        readinessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 80,
                                scheme: "HTTP"
                            }
                        },
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 80,
                                scheme: "HTTP"
                            },
                            initialDelaySeconds: 10,
                            timeoutSeconds: 1
                        },
                        env: [
                            {
                                name: "POD_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "metadata.name"
                                    }
                                }
                            },
                            {
                                name: "POD_NAMESPACE",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "metadata.namespace"
                                    }
                                }
                            },
                            {
                                name: "KUBECONFIG",
                                "value": "/etc/kubernetes/kubeconfig"
                            }
                        ],
                        ports: [
                            {
                                containerPort: 80,
                                hostPort: 80
                            },
                            {
                                containerPort: 443,
                                hostPort: 8443,
                            }
                        ],
                        args: [
                            "--default-backend-service=$(POD_NAMESPACE)/default-http-backend",
                            "--sync-period=5s"
                        ],
                        volumeMounts: [
                            flowsnakeconfigmapmount.kubeconfig_volumeMounts,
                            flowsnakeconfigmapmount.cert_volumeMounts
                        ]
                    }
                ],
                volumes: [
                    flowsnakeconfigmapmount.kubeconfig_volume,
                    flowsnakeconfigmapmount.cert_volume
                ],
                nodeSelector: {
                    vippool: "true"
                }
            }
        }
    }
}
