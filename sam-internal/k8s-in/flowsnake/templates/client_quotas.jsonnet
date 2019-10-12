local flowsnake_clients = import "flowsnake_direct_clients.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

if std.length([c for c in flowsnake_clients.clients if "quota" in c]) == 0 then "SKIP" else
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: std.join(
[],
        [
            (if std.objectHas(client, "quota") then
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
            else [])
            for client in flowsnake_clients.clients
        ],
    ),
}
