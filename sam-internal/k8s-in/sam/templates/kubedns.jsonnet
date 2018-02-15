local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
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
        replicas: 1,
        revisionHistoryLimit: 2,
        selector: {
            matchLabels: {
                "k8s-app": "kube-dns",
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
                        image: samimages.kubedns,
                        imagePullPolicy: "IfNotPresent",
                        livenessProbe: {
                            failureThreshold: 5,
                            httpGet: {
                                path: "/healthcheck/kubedns",
                                port: 10054,
                                scheme: "HTTP",
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
                                memory: "170Mi",
                            },
                            requests: {
                                cpu: "100m",
                                memory: "70Mi",
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
                            "--cache-size=1000",
                            "--log-facility=-",
                            "--server=/cluster.local/127.0.0.1#10053",
                            "--server=/in-addr.arpa/127.0.0.1#10053",
                            "--server=/ip6.arpa/127.0.0.1#10053",
                        ],
                        image: samimages.kubednsmasq,
                        imagePullPolicy: "IfNotPresent",
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
                                memory: "20Mi",
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
                        image: samimages.kubednssidecar,
                        imagePullPolicy: "IfNotPresent",
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
                                memory: "20Mi",
                            },
                        },
                        terminationMessagePath: "/dev/termination-log",
                        terminationMessagePolicy: "File",
                    },
                ],
                dnsPolicy: "Default",
                nodeSelector: {
                    pool: "prd-sam",
                },
                restartPolicy: "Always",
                schedulerName: "default-scheduler",
                securityContext: {},
                serviceAccount: "kube-dns",
                serviceAccountName: "kube-dns",
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
} else "SKIP"
