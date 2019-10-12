local configs = import "config.jsonnet";
local flowsnake_clients = import "flowsnake_direct_clients.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";

if std.length(flowsnake_clients.clients) == 0 then "SKIP" else
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
    ],
}
