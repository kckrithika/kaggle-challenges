local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

if flowsnakeconfig.is_v1_enabled then
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
                "k8s-app": label_node["k8s-app"],
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "nginx-ingress-lb",
                    "k8s-app": "nginx-ingress-lb",
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "NginxIngressController",
                },
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
                                exec: {
                                    # Verify health endpoint reachability AND kill once daily to ensure fresh PKI cert
                                    # See also https://github.com/kubernetes/kubernetes/issues/37218#issuecomment-372887460
                                    # Note: bash ps etime syntax is <days>-<hours>:<minutes>:<seconds>, but busybox is
                                    # <minutes>:<seconds> even for large minute counts. Use 2000 minutes ( ~ 1.4 days) as
                                    # the threshold.
                                    # grep -c (count) | grep 0 will yield an error if the count non-zero and thus fail the
                                    # liveness check.
                                    #
                                    # For the nginx case, we have bash ps etime syntax, not busybox syntax.
                                    # After a day of running, it switches to this format of (number of days)-(h):(m):(s)
                                    # "ps -o comm,etime | grep nginx-ingress"
                                    # nginx-ingress-c  2-01:08:02
                                    #
                                    # We'll grep for the dash delimiter that indicates it has been running for at least a day.
                                    command: [
                                        "sh",
                                        "-c",
                                        "reply=$(curl -s -o /dev/null -w %{http_code} http://127.0.0.1:80/healthz); if [ \"$reply\" -lt 200 -o \"$reply\" -ge 400 ]; then exit 1; fi; ps -o comm,etime | grep nginx-ingress | grep -cE '[1-9]-[0-9]' | grep -q 0",
                                    ],
                                },
                                initialDelaySeconds: 60,
                                periodSeconds: 10,
                                successThreshold: 1,
                                failureThreshold: 5,
                                timeoutSeconds: 5,
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
                        args: ["-endpoint", "flowsnake/" + flowsnakeconfig.role_munge_for_estate("api") + ":DATACENTER_ALLENV:443:" + flowsnakeconfig.fleet_vips[estate], "-path", "-.-." + kingdom + ".-.flowsnake", "-spod", "NONE"],
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
} else "SKIP"
