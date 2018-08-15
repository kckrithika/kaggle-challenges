local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.kubedns then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            "addonmanager.kubernetes.io/mode": "Reconcile",
            "k8s-app": "kube-dns",
            "kubernetes.io/cluster-service": "true",
        } + configs.ownerLabel.sam,
        name: "kube-dns",
        namespace: "kube-system",
    },
    spec: {
        progressDeadlineSeconds: 600,
        replicas: 3,
        revisionHistoryLimit: 2,
        selector: {
            matchLabels: {
                "k8s-app": "kube-dns",
            },
        },
        strategy: {
            rollingUpdate: {
                maxSurge: 0,
                maxUnavailable: 1,
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
                } + configs.ownerLabel.sam,
            },
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        args: [
                            "--domain=" + configs.dnsdomain + ".",
                            "--dns-port=10053",
                            "--kubecfg-file=/etc/kubernetes/kubeconfig",
                            "--v=2",
                        ],
                        env: [
                            {
                                name: "PROMETHEUS_PORT",
                                value: "10055",
                            },
                            {
                                name: "TEST",
                                value: "2",
                            },
                            configs.kube_config_env,
                        ],
                        image: samimages.kubedns,
                        imagePullPolicy: "IfNotPresent",
                        livenessProbe: if configs.estate == "prd-samdev" then {
                            failureThreshold: 5,
                            exec: {
                                command: [
                                    "sh",
                                    "-c",
                                    "/scripts/cert-age.sh && nslookup kubernetes.default.svc.cluster.local 127.0.0.1:10053 > /dev/null",
                                ],
                            },
                            initialDelaySeconds: 60,
                            periodSeconds: 10,
                            successThreshold: 1,
                            timeoutSeconds: 5,
                        } else {
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
                            configs.kube_config_volume_mount,
                        ] + if configs.estate == "prd-samdev" then [{
                                mountPath: "/scripts",
                                name: "cert-age",
                            }] else [],
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
                            "--server=/" + configs.dnsdomain + "/127.0.0.1#10053",
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
                            "--probe=kubedns,127.0.0.1:10053,kubernetes.default.svc." + configs.dnsdomain + ",5,A",
                            "--probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc." + configs.dnsdomain + ",5,A",
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
                nodeSelector: if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
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
                    configs.kube_config_volume,
                ] + (
if configs.estate == "prd-samdev" then [{
                        configMap: {
                            defaultMode: 511,
                            name: "cert-age",
                        },
                        name: "cert-age",
                    }] else []
                ),
            },
        },
    },
} else "SKIP"
