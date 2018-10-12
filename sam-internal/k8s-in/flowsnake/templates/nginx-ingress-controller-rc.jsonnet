local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flag_fs_metric_labels = std.objectHas(flowsnake_images.feature_flags, "fs_metric_labels");
{
    local label_node = self.spec.template.metadata.labels,
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
                name: label_node.name,
                "k8s-app": label_node["k8s-app"],
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "nginx-ingress-lb",
                    "k8s-app": "nginx-ingress-lb",
                } + if flag_fs_metric_labels then {
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "NginxIngressController",
                } else {},
            },
            spec: {
                terminationGracePeriodSeconds: 60,
                containers: [
                    {
                        name: "nginx-ingress-lb",
                        image: flowsnake_images.ingress_controller_nginx,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
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
                            {
                                name: "KUBECONFIG",
                                value: "/etc/kubernetes/kubeconfig",
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
                            else (
                                [
                                 {
                                     name: "flowsnake-tls-secret",
                                     mountPath: "/etc/ssl/certs",
                                     readOnly: true,
                                 },
                                ] +
                                certs_and_kubeconfig.kubeconfig_volumeMounts +
                                certs_and_kubeconfig.k8s_cert_volumeMounts
)
                        ),
                    },
                ] + if flowsnakeconfig.is_minikube then [] else [
                    {
                        name: "beacon",
                        image: flowsnake_images.beacon,
                        args: ["-endpoint", "flowsnake/" + flowsnakeconfig.fleet_api_roles[estate] + ":DATACENTER_ALLENV:443:" + flowsnakeconfig.fleet_vips[estate], "-path", "-.-." + kingdom + ".-.flowsnake", "-spod", "NONE"],
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
                    else (
                        [
                            {
                                name: "flowsnake-tls-secret",
                                secret: {
                                    secretName: "flowsnake-tls",
                                },
                            },
                        ] +
                        certs_and_kubeconfig.kubeconfig_volume +
                        certs_and_kubeconfig.k8s_cert_volume
)
                ),
                [if estate == "prd-data-flowsnake" then "nodeSelector"]: {
                    vippool: "true",
                },
            },
        },
    },
}
