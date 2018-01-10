local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
local estate = std.extVar("estate");
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
                        image: flowsnakeimage.ingress_controller_nginx,
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
                            "--annotations-prefix=ingress.kubernetes.io",
                            "--sync-period=30s",
                            "--kubeconfig=/etc/kubernetes/kubeconfig"
                        ],
                        volumeMounts: [
                            {
                                mountPath: "/etc/ssl/certs/ssl-cert-snakeoil.pem",
                                name: "server-certificate",
                                readOnly: true
                            },
                            {
                                mountPath: "/etc/ssl/private/ssl-cert-snakeoil.key",
                                name: "server-key",
                                readOnly: true
                            }
                        ] +
                        flowsnakeconfigmapmount.kubeconfig_volumeMounts +
                        flowsnakeconfigmapmount.cert_volumeMounts
                    }
                ],
                volumes: [
                    {
                        name: "server-certificate",
                        hostPath: {
                            path: "/etc/pki_service/platform/platform-server/certificates/platform-server.pem"
                        }
                    },
                    {
                        name: "server-key",
                        hostPath: {
                            path: "/etc/pki_service/platform/platform-server/keys/platform-server-key.pem"
                        }
                    } 
                ] +
                flowsnakeconfigmapmount.kubeconfig_volume +
                flowsnakeconfigmapmount.cert_volume,
                [if estate == "prd-data-flowsnake" then "nodeSelector"]: {
                    vippool: "true"
                }
            }
        }
    }
}
