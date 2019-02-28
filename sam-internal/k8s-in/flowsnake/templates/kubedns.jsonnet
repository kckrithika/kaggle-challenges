local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };

if !flowsnake_config.kubedns_manifests_enabled then
"SKIP"
else
{
    local label_node = self.spec.template.metadata.labels,
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            "addonmanager.kubernetes.io/mode": "Reconcile",
            "k8s-app": "kube-dns",
            "kubernetes.io/cluster-service": "true",
        },
        name: "kube-dns",
        namespace: "kube-system",
    },
    spec: {
        progressDeadlineSeconds: 600,
        replicas: 3,
        revisionHistoryLimit: 2,
        selector: {
            matchLabels: {
                "k8s-app": label_node["k8s-app"],
            },
        },
        strategy: {
            rollingUpdate: {
                maxSurge: "10%",
                maxUnavailable: 0,
            },
            type: "RollingUpdate",
        },
        template: {
            metadata: {
                annotations: {
                    "scheduler.alpha.kubernetes.io/critical-pod": "",
                },
                creationTimestamp: null,
                labels: {
                    "k8s-app": "kube-dns",
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "KubeDns",
                },
            },
            spec: {
                containers: [
                    {
                        args: [
                            "--domain=cluster.local.",
                            "--dns-port=10053",
                            "--kubecfg-file=/etc/kubernetes/kubeconfig",
                            "--v=2",
                        ],
                        env: [
                            {
                                name: "PROMETHEUS_PORT",
                                value: "10055",
                            },
                        ],
                        image: flowsnake_images.kubedns,
                        imagePullPolicy: flowsnake_config.default_image_pull_policy,
                        livenessProbe: {
                            failureThreshold: 5,
                            exec: {
                                # Verify responding to DNS requests AND kill once daily to ensure fresh PKI cert
                                # See also https://github.com/kubernetes/kubernetes/issues/37218#issuecomment-372887460
                                # Note: bash ps etime syntax is <days>-<hours>:<minutes>:<seconds>, but busybox is
                                # <minutes>:<seconds> even for large minute counts. Use 2000 minutes ( ~ 1.4 days) as
                                # the threshold.
                                # grep -c (count) | grep 0 will yield an error if the count non-zero and thus fail the
                                # liveness check.
                                # grep explicitly for the kube-dns process because the pause container will survive a
                                # liveness probe-based pod restart.
                                command: [
                                    "sh",
                                    "-c",
                                    "nslookup kubernetes.default.svc.cluster.local 127.0.0.1:10053 > /dev/null && ps -o comm,etime | grep kube-dns | grep -cE '[2-9][0-9][0-9][0-9]:' | grep -q 0",
                                ],
                            },
                            initialDelaySeconds: 60,
                            periodSeconds: 10,
                            successThreshold: 1,
                            timeoutSeconds: 5,
                        },
                        name: "kubedns",
                        ports: [
                            {
                                containerPort: 10053,
                                name: "dns-local",
                                protocol: "UDP",
                            },
                            {
                                containerPort: 10053,
                                name: "dns-tcp-local",
                                protocol: "TCP",
                            },
                            {
                                containerPort: 10055,
                                name: "metrics",
                                protocol: "TCP",
                            },
                        ],
                        readinessProbe: {
                            failureThreshold: 3,
                            httpGet: {
                                path: "/readiness",
                                port: 8081,
                                scheme: "HTTP",
                            },
                            initialDelaySeconds: 3,
                            periodSeconds: 10,
                            successThreshold: 1,
                            timeoutSeconds: 5,
                        },
                        resources: {
                            limits: {
                                memory: "500Mi",
                            },
                            requests: {
                                cpu: "100m",
                                memory: "300Mi",
                            },
                        },
                        terminationMessagePath: "/dev/termination-log",
                        terminationMessagePolicy: "File",
                        volumeMounts: [
                            {
                                mountPath: "/etc/kubernetes",
                                name: "kubernetes",
                            },
                            {
                                mountPath: "/etc/pki_service",
                                name: "maddog-certs",
                            },
                            {
                                mountPath: "/data/certs",
                                name: "certs",
                            },
                        ],
                    },
                    {
                        args: [
                            "-v=2",
                            "-logtostderr",
                            "-configDir=/etc/k8s/dns/dnsmasq-nanny",
                            "-restartDnsmasq=true",
                            "--",
                            "-k",
                            "--cache-size=" + std.toString(flowsnake_config.kubedns_cache_size),
                            "--log-facility=-",
                            "--server=/cluster.local/127.0.0.1#10053",
                            "--server=/in-addr.arpa/127.0.0.1#10053",
                            "--server=/ip6.arpa/127.0.0.1#10053",
                        ] + if flowsnake_config.kubedns_log_queries then [
                            "--log-queries",
                            "--log-async",
                        ] else [],
                        image: flowsnake_images.kubednsmasq,
                        imagePullPolicy: flowsnake_config.default_image_pull_policy,
                        livenessProbe: {
                            failureThreshold: 5,
                            httpGet: {
                                path: "/healthcheck/dnsmasq",
                                port: 10054,
                                scheme: "HTTP",
                            },
                            initialDelaySeconds: 60,
                            periodSeconds: 10,
                            successThreshold: 1,
                            timeoutSeconds: 5,
                        },
                        name: "dnsmasq",
                        ports: [
                            {
                                containerPort: 53,
                                name: "dns",
                                protocol: "UDP",
                            },
                            {
                                containerPort: 53,
                                name: "dns-tcp",
                                protocol: "TCP",
                            },
                        ],
                        resources: {
                            requests: {
                                cpu: "150m",
                                memory: "200Mi",
                            },
                        },
                        terminationMessagePath: "/dev/termination-log",
                        terminationMessagePolicy: "File",
                    },
                    {
                        args: [
                            "--v=2",
                            "--logtostderr",
                            "--probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.cluster.local,5,A",
                            "--probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.cluster.local,5,A",
                        ],
                        image: flowsnake_images.kubednssidecar,
                        imagePullPolicy: flowsnake_config.default_image_pull_policy,
                        livenessProbe: {
                            failureThreshold: 5,
                            httpGet: {
                                path: "/metrics",
                                port: 10054,
                                scheme: "HTTP",
                            },
                            initialDelaySeconds: 60,
                            periodSeconds: 10,
                            successThreshold: 1,
                            timeoutSeconds: 5,
                        },
                        name: "sidecar",
                        ports: [
                            {
                                containerPort: 10054,
                                name: "metrics",
                                protocol: "TCP",
                            },
                        ],
                        resources: {
                            requests: {
                                cpu: "10m",
                                memory: "200Mi",
                            },
                        },
                        terminationMessagePath: "/dev/termination-log",
                        terminationMessagePolicy: "File",
                    },
                ],
                dnsPolicy: "Default",
                restartPolicy: "Always",
                hostNetwork: true,
                schedulerName: "default-scheduler",
                securityContext: {},
                terminationGracePeriodSeconds: 30,
                tolerations: [
                    {
                        key: "CriticalAddonsOnly",
                        operator: "Exists",
                    },
                ],
                volumes: [
                    {
                        hostPath: {
                            path: "/etc/kubernetes",
                        },
                        name: "kubernetes",
                    },
                    {
                        hostPath: {
                            path: "/etc/pki_service",
                        },
                        name: "maddog-certs",
                    },
                    {
                        hostPath: {
                            path: "/data/certs",
                        },
                        name: "certs",
                    },
                ],
            },
        },
    },
}
