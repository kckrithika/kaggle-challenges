local flowsnake_clients = import "flowsnake_direct_clients.jsonnet";

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
                },
            },
        }
        for client in flowsnake_clients.clients
    ] + std.join([], [(if std.objectHas(client, "quota") then
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
         else []) for client in flowsnake_clients.clients]),
}
) else "SKIP"
