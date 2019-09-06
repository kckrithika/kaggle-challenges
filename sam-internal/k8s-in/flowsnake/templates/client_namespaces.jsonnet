local flowsnake_clients = import "flowsnake_direct_clients.jsonnet";
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
            [{
               apiVersion: "v1",
               kind: "ConfigMap",
               metadata: {
                   name: "prometheus-server-conf" + client.namespace,
                   labels: {
                       name: "prometheus-server-conf" + client.namespace,
                   },
                   namespace: client.namespace,
               },
               data: {
                   "prometheus.json": client.prometheus_config,
               },
            }]
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
