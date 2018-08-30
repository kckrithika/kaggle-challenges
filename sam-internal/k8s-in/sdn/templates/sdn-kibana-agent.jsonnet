local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then configs.deploymentBase("sdn") {
    spec+: {
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
                } + configs.ownerLabel.sdn,
                namespace: "sam-system",
            },
        },
    },
    metadata: {
        labels: {
            name: "sdn-kibana-agent",
        } + configs.ownerLabel.sdn,
        name: "sdn-kibana-agent",
        namespace: "sam-system",
    },
} else "SKIP"
