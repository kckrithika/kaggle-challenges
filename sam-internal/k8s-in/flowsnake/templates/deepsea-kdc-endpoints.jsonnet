local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.deepsea_enabled then {
    apiVersion: "v1",
    kind: "Endpoints",
    metadata: {
        name: "deepsea-kdc",
        namespace: "default",
    },
    subsets: [
        {
            addresses: [
                {
                    ip: "10.231.0.194",
                },
            ],
            ports: [
                {
                    port: 9089,
                    protocol: "TCP",
                },
            ],
        },
    ],
} else "SKIP"
