local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if (std.count(flowsnakeconfig.deepsea_enabled, kingdom + "/" + estate) > 0) then {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "deepsea-kdc",
        namespace: "default",
    },
    spec: {
        type: "ExternalName",
        externalName: "hdaas-mnds4-1-prd.eng.sfdc.net",
        ports: [
            {
                protocol: "UDP",
                port: 88,
                targetPort: 9089,
            },
        ],
    },
} else "SKIP"
