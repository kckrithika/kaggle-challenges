{
    local configs = import "config.jsonnet",
    local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile },

    templ(estate, port):: configs.daemonSetBase("sam") {
        spec+: {
            template: {
                spec: {
                    hostNetwork: true,
                    serviceAccountName: "sloop",
                    containers: [
                        {
                            name: "sloopds",
                            resources: {
                                requests: {
                                    cpu: "1",
                                    memory: "12Gi",
                                },
                                limits: {
                                    cpu: "1",
                                    memory: "12Gi",
                                },
                            },
                            args: [
                                "--config=/sloopconfig/sloop.yaml",
                                "--port=" + port,
                                "--context=" + estate,
                            ],
                            command: [
                                "/sloop",
                            ],
                            livenessProbe: {
                                    httpGet: {
                                        path: "/healthz",
                                        port: port,
                                    },
                                    initialDelaySeconds: 1800,
                                    timeoutSeconds: 5,
                                    periodSeconds: 10,
                                    successThreshold: 1,
                                    failureThreshold: 3,
                                },
                            readinessProbe: {
                                    httpGet: {
                                        path: "/healthz",
                                        port: port,
                                    },
                                    timeoutSeconds: 5,
                                    periodSeconds: 10,
                                    successThreshold: 1,
                                    failureThreshold: 3,
                                },
                            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/sjawad/sloop:sjawad-20200127_155000-8b51ce2",
                            volumeMounts: [
                                {
                                    name: "sloop-data",
                                    mountPath: "/data/",
                                },
                                {
                                    name: "sloopconfig",
                                    mountPath: "/sloopconfig/",
                                },
                            ],
                            ports: [
                                {
                                    containerPort: port,
                                    protocol: "TCP",
                                },
                            ],
                        },
                        {
                            name: "prometheus",
                            args: [
                                "--config.file",
                                "/prometheusconfig/prometheus.json",
                            ],
                            image: samimages.prometheus,
                            volumeMounts: [
                                {
                                    name: "prom-data",
                                    # For some reason we are getting permission denied on the host-mount
                                    # Moving this mount will mean prometheus writes to local docker FS
                                    # TODO: Fix this properly
                                    mountPath: "/dummy-prometheus/data",
                                },
                                {
                                    name: "sloopconfig",
                                    mountPath: "/prometheusconfig",
                                },
                            ],
                            ports: [
                                {
                                    containerPort: 9090,
                                    protocol: "TCP",
                                },
                            ],
                        },
                    ],
                    volumes+: [
                        {
                            hostPath: {
                                path: "/data/sloop-data",
                            },
                            name: "sloop-data",
                        },
                        {
                            hostPath: {
                                path: "/data/sloop-prom-data",
                            },
                            name: "prom-data",
                        },
                        {
                            configMap: {
                                name: "sloop",
                            },
                            name: "sloopconfig",
                        },
                    ],
                    nodeSelector:
                        (
                            if configs.estate == "prd-sam" then
                                [{ master: "true" }]
                            else
                                [{ "node.sam.sfdc.net/role": "samcompute" }, { pool: "prd-samtwo" }]
                        ),
                },
                metadata: {
                    labels: {
                        app: "sloopds",
                        apptype: "monitoring",
                        daemonset: "true",
                    } + configs.ownerLabel.sam,
                    namespace: "sam-system",
                },
            },
            updateStrategy: {
                type: "RollingUpdate",
                rollingUpdate: {
                    maxUnavailable: "25%",
                },
            },
        },
        metadata+: {
            labels: {
                name: "sloopds-" + estate,
            } + configs.ownerLabel.sam,
            name: "sloopds-" + estate,
        },
    },
}
