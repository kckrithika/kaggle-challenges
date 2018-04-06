local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "sdn-elasticsearch-svc",
            namespace: "sam-system",
        },
        spec: {
            clusterIP: sdnconfigs.sdn_elasticsearch_cluster_ip,
            ports: [
                {
                    name: "sdn-elasticsearch-port",
                    port: portconfigs.sdn.sdn_elasticsearch,
                    protocol: "TCP",
                    targetPort: portconfigs.sdn.sdn_elasticsearch,
                },
            ],
            selector: {
                name: "sdn-elasticsearch",
            },
        },
} else "SKIP"
