local configs = import "config.jsonnet";
local flowsnake_clients = import "flowsnake_direct_clients.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";

if std.length(flowsnake_clients.clients) > 0 then (
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        {
            kind: "Namespace",
            apiVersion: "v1",
            metadata: {
                name: client.namespace,
                annotations: {
                    "sfdc.net/flowsnake.owner_name": client.owner_name,
                    "sfdc.net/pki-namespace": client.pki_namespace,
                 },
                labels: {
                    "madkub-injector": "enabled",
                    "spark-operator-webhook": "enabled",

                } + (if flowsnake_config.service_mesh_enabled then
                    { "service-mesh-injector": "enabled" }
                else {}),
            },

        }
        for client in flowsnake_clients.clients
    ]
    + std.join(
[], [(if std.objectHas(client, "prometheus_config") then
    [
        # ConfigMap specifying where to find client prometheus config
        {
            apiVersion: "v1",
            kind: "ConfigMap",
            metadata: {
                name: "prometheus-server-conf-" + client.namespace,
                    labels: {
                        name: "prometheus-server-conf-" + client.namespace,
                    },
                namespace: client.namespace,
            },
            data: {
                "prometheus.json": std.toString(client.prometheus_config),
            },
        },
        # Service accounts needed by Prometheus in client namespace
        {
            kind: "ServiceAccount",
            apiVersion: "v1",
            automountServiceAccountToken: true,
            metadata: {
                namespace: client.namespace,
                name: "prometheus-scraper-" + client.namespace + "-serviceaccount",
            },
        },
        {
            kind: "RoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "prometheus-scraper-binding-" + client.namespace,
                namespace: client.namespace,
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
                roleRef: {
                    kind: "Role",
                    name: "prometheus-scraper-role-" + client.namespace,
                    apiGroup: "rbac.authorization.k8s.io",
                },
                subjects: [
                    {
                        kind: "ServiceAccount",
                        name: "prometheus-scraper-" + client.namespace + "-serviceaccount",
                        namespace: client.namespace,
                    },
                ],
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1",
            kind: "Role",
            metadata: {
                name: "prometheus-scraper-role-" + client.namespace,
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            rules: [
                {
                    apiGroups: [""],
                    resources: ["pods"],
                    verbs: ["get", "list", "watch"],
                },
            ],
        },
    ] +
    [
        configs.deploymentBase(client.namespace) {
            local label_node = self.spec.template.metadata.labels,
            metadata: {
                labels: {
                    service: "prometheus-scraper-" + client.namespace,
                },
                name: "prometheus-scraper-" + client.namespace,
                namespace: client.namespace,
            },
            spec+: {
                replicas: 2,
                minReadySeconds: 15,
                selector: {
                    matchLabels: {
                        service: label_node.name,
                    },
                },
                template: {
                    metadata: {
                        labels: {
                            apptype: "monitoring",
                            service: "prometheus-scraper",
                            flowsnakeOwner: client.namespace,
                            flowsnakeRole: "PrometheusScraper",
                            name: "prometheus-scraper",
                        },
                    },
                    spec: {
                        serviceAccountName: "prometheus-scraper-" + client.namespace + "-serviceaccount",
                        containers: [
                            {
                                args: [
                                  "--config.file=/etc/config/prometheus.json",
                                  "--storage.tsdb.path=/prometheus-storage",
                                  "--web.external-url=http://localhost/",
                                  "--web.enable-lifecycle",
                                ],
                                image: flowsnake_images.prometheus_scraper,
                                name: "prometheus",
                                ports: [
                                    {
                                        containerPort: 9090,
                                    },
                                ],
                                volumeMounts: [
                                  {
                                    mountPath: "/prometheus-storage",
                                    name: "prometheus-storage-volume",
                                  },
                                  {
                                    mountPath: "/etc/config",
                                    name: "prometheus-server-conf-" + client.namespace,
                                  },
                                ],
                                livenessProbe: {
                                    httpGet: {
                                        path: "/metrics",
                                        port: 9090,
                                        scheme: "HTTP",
                                    },
                                    initialDelaySeconds: 30,
                                    periodSeconds: 10,
                                },
                            },
                            {
                                args: [
                                  "--serviceName=flowsnake",
                                  "--subserviceName=" + client.namespace,
                                  "--tagDefault=superpod:NONE",
                                  "--tagDefault=datacenter:" + kingdom,
                                  "--tagDefault=estate:" + estate,
                                  "--batchSize=512",
                                  "--funnelUrl=" + flowsnake_config.funnel_endpoint,
                                ],
                                image: flowsnake_images.funnel_writer,
                                name: "funnel-writer",
                                ports: [
                                  {
                                    containerPort: 8000,
                                  },
                                ],
                                volumeMounts: [
                                  {
                                    mountPath: "/prometheus-storage",
                                    name: "prometheus-storage-volume",
                                  },
                                ],
                                livenessProbe: {
                                    httpGet: {
                                        path: "/",
                                        port: 8000,
                                        scheme: "HTTP",
                                    },
                                    initialDelaySeconds: 30,
                                    periodSeconds: 10,
                                },
                            },
                        ],
                        restartPolicy: "Always",
                        volumes: [
                              {
                                name: "prometheus-server-conf-" + client.namespace,
                                  configMap: {
                                    name: "prometheus-server-conf-" + client.namespace,
                                  },
                              },
                              {
                                name: "prometheus-storage-volume",
                                emptyDir: {
                                  medium: "Memory",
                                },
                              },
                        ],
                    },
                },
            },
        },
]
        else []) for client in flowsnake_clients.clients],
    )
    + std.join(
[], [(if std.objectHas(client, "quota") then
        [{
            kind: "ResourceQuota",
            apiVersion: "v1",
            metadata: {
                name: "quota-" + client.namespace,
                namespace: client.namespace,
            },
            spec: {
                hard: client.quota,
            },
        }]
    else []) for client in flowsnake_clients.clients],
    ),
}
)
else "SKIP"
