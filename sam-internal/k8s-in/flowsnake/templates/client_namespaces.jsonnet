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
                      "prometheus.json": client.prometheus_config,
                  },
            },
            {
                  apiVersion: "extensions/v1beta1",
                  kind: "Deployment",
                  metadata: {
                      labels: {
                          service: "prometheus-scraper-" + client.namespace,
                      },
                      name: "prometheus-scraper-" + client.namespace,
                      namespace: client.namespace,
                  },
                  spec+: {
                    replicas: if std.objectHas(flowsnake_images.feature_flags, "prometheus_ha") then 2 else 1,
                    minReadySeconds: 15,
                    selector: {
                      matchLabels: {
                        service: "prometheus-scraper-" + client.namespace,
                      },
                    },
                    template: {
                      metadata: {
                        labels: {
                          apptype: "monitoring",
                          service: "prometheus-scraper",
                          flowsnakeOwner: "dva-transform",
                          flowsnakeRole: "PrometheusScraper",
                          name: "prometheus-scraper",
                        },
                        },
                      },
                      spec: {
                        serviceAccountName: "prometheus-scraper",
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
                                name: "prometheus-server-conf",
                              },
                              {
                                mountPath: "/etc/pki_service",
                                name: "certs-volume",
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
                              "--subserviceName=NONE",
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
                            name: "prometheus-server-conf",
                              configMap: {
                                name: "prometheus-server-conf",
                              },
                          },
                          {
                            name: "prometheus-storage-volume",
                            emptyDir: {
                              medium: "Memory",
                            },
                          },
                          {
                            hostPath: {
                                path: "/etc/pki_service",
                            },
                            name: "certs-volume",
                          },
                        ],
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
) else "SKIP"
