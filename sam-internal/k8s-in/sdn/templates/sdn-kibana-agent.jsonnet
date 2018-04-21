local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-kibana-agent",
                        image: sdnimages.elkagents,
                        command: [
                            "/sdn/sdn-kibana-agent",
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--elasticsearchUrl=" + sdnconfigs.elasticsearchUrl,
                        ],
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "sdn-kibana-agent",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-kibana-agent",
        },
        name: "sdn-kibana-agent",
        namespace: "sam-system",
    },
} else "SKIP"
