local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.deepsea_enabled then {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "deepsea-kdc",
        namespace: "default",
    },
    spec: {
        # TODO: Figure out how to use DNS name instead of hard-coded IP
        # type: "ExternalName",
        # externalName: "hdaas-mnds4-1-prd.eng.sfdc.net",
        type: "ClusterIP",
        clusterIP: "10.254.209.167",
        ports: [
            {
                protocol: "UDP",
                port: 88,
                targetPort: 9089,
            },
        ],
    },
} else "SKIP"
