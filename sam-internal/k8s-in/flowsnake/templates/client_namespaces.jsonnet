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
            },
        }
        for client in flowsnake_clients.clients
    ],
}
) else "SKIP"
