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
                        name: "sdn-kibana",
                        image: sdnimages.hyperelk,
                        env: [
                                {
                                    name: "RUN",
                                    value: "kibana",
                                },
                                {
                                    name: "ELASTICSEARCH_URL",
                                    value: sdnconfigs.elasticsearchUrl,
                                },
                                {
                                    name: "SERVER_PORT",
                                    value: std.toString(portconfigs.sdn.sdn_kibana),
                                },
                        ],
                        ports: [
                            {
                                containerPort: portconfigs.sdn.sdn_kibana,
                            },
                        ],
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "sdn-kibana",
                    apptype: "monitoring",
                } + configs.ownerLabel.sdn,
                namespace: "sam-system",
            },
        },
    },
    metadata: {
        labels: {
            name: "sdn-kibana",
        } + configs.ownerLabel.sdn,
        name: "sdn-kibana",
        namespace: "sam-system",
    },
} else "SKIP"
