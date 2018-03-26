local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
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
            "k8s-app": "nginx-ingress-lb",
        },
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                "k8s-app": "nginx-ingress-lb",
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "nginx-ingress-lb",
                    "k8s-app": "nginx-ingress-lb",
                },
            },
            spec: {
                terminationGracePeriodSeconds: 60,
                containers: [
                    {
                        name: "nginx-ingress-lb",
                        image: flowsnakeimage.ingress_controller_nginx,
                        imagePullPolicy: if flowsnakeconfig.is_minikube then "Never" else "Always",
                        readinessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 80,
                                scheme: "HTTP",
                            },
                        },
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 80,
                                scheme: "HTTP",
                            },
                            initialDelaySeconds: 10,
                            timeoutSeconds: 1,
                        },
                        env: [
                            {
                                name: "POD_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "metadata.name",
                                    },
                                },
                            },
                            {
                                name: "POD_NAMESPACE",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "metadata.namespace",
                                    },
                                },
                            },
                        ],
                        ports: [
                            {
                                containerPort: 80,
                                hostPort: 80,
                            },
                            {
                                containerPort: 443,
                                # NodePort allowed range is different in Minikube; compensate accordingly.
                                hostPort: if flowsnakeconfig.is_minikube then 443 else 8443,
                            },
                        ],
                        args: [
                            "--default-backend-service=$(POD_NAMESPACE)/default-http-backend",
                            "--sync-period=30s",
                            "--kubeconfig=/etc/kubernetes/kubeconfig",
                        ],
                        volumeMounts: (
                            if flowsnakeconfig.is_minikube then
                                [
                                 {
                                     name: "flowsnake-tls-secret",
                                     mountPath: "/etc/ssl/certs",
                                     readOnly: true,
                                 },
                                ]
                            else if flowsnakeconfig.maddog_enabled then
                                [
                                 {
                                     name: "flowsnake-tls-secret",
                                     mountPath: "/etc/ssl/certs",
                                     readOnly: true,
                                 },
                                ] +
                                flowsnakeconfigmapmount.kubeconfig_volumeMounts +
                                flowsnakeconfigmapmount.k8s_cert_volumeMounts
                            else flowsnakeconfigmapmount.kubeconfig_volumeMounts +
                                flowsnakeconfigmapmount.k8s_cert_volumeMounts
                        ),
                    },
                ],
                volumes: (
                    if flowsnakeconfig.is_minikube then
                        [
                            {
                                name: "flowsnake-tls-secret",
                                secret: {
                                    secretName: "flowsnake-tls",
                                },
                            },
                        ]
                    else if flowsnakeconfig.maddog_enabled then
                        [
                            {
                                name: "flowsnake-tls-secret",
                                secret: {
                                    secretName: "flowsnake-tls",
                                },
                            },
                        ] +
                        flowsnakeconfigmapmount.kubeconfig_volume +
                        flowsnakeconfigmapmount.k8s_cert_volume
                    else flowsnakeconfigmapmount.kubeconfig_volume +
                        flowsnakeconfigmapmount.k8s_cert_volume
                ),
                [if estate == "prd-data-flowsnake" then "nodeSelector"]: {
                    vippool: "true",
                },
            },
        },
    },
}
